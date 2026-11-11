import asyncio
import json
from datetime import datetime
from pathlib import Path

from automation.helpers.browser import BrowserSession
from automation.helpers.evidence import EvidenceRecorder
from automation.helpers.documenter import generate_markdown

BASE = Path(__file__).resolve().parent.parent
CONFIG = BASE / "automation" / "config" / "scenarios.json"
EXECUTIONS = BASE / "executions"
DOCS = BASE / "documentation"

def load_scenarios():
    return json.loads(CONFIG.read_text(encoding="utf-8"))

def check_environment():
    try:
        import playwright
    except ImportError:
        print("ERRO: Playwright não está instalado.")
        return 1
    print("Playwright: OK")
    print("Juice Shop esperado em: http://localhost:3000")
    return 0

async def dispatch(scenario, session, recorder):
    from automation.tests.test_idt import run_idt01, run_idt02, run_idt03, run_idt04
    from automation.tests.test_cat import run_cat01, run_cat02, run_cat03
    funcs = {
        "CEN-IDT-01": run_idt01,
        "CEN-IDT-02": run_idt02,
        "CEN-IDT-03": run_idt03,
        "CEN-IDT-04": run_idt04,
        "CEN-CAT-01": run_cat01,
        "CEN-CAT-02": run_cat02,
        "CEN-CAT-03": run_cat03,
    }
    if scenario["id"] not in funcs:
        raise ValueError("Cenário não implementado nesta fase.")
    return await funcs[scenario["id"]](session, recorder)

async def run_scenario(scenario_id, headed=False):
    cfg = load_scenarios()
    scenario = next((s for s in cfg["scenarios"] if s["id"] == scenario_id), None)
    if not scenario:
        raise SystemExit(f"Cenário inexistente: {scenario_id}")
    if not scenario.get("implemented"):
        raise SystemExit(f"Cenário ainda não implementado: {scenario_id}")
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    out = EXECUTIONS / scenario_id / f"run-{stamp}"
    async with BrowserSession(cfg["base_url"], headed=headed) as session:
        await session.open()
        recorder = EvidenceRecorder(out, scenario)
        try:
            status, note = await dispatch(scenario, session, recorder)
        except Exception as exc:
            status, note = "inconclusive", f"Execução inconclusiva: {type(exc).__name__}: {exc}"
        result = recorder.finalize(status, note)
    doc = DOCS / scenario_id / f"{out.name}.md"
    doc.parent.mkdir(parents=True, exist_ok=True)
    generate_markdown(result, doc)
    print(f"[{status}] {scenario_id}")
    print(f"JSON: {out / 'execution.json'}")
    print(f"MD: {doc}")

async def run_all(headed=False):
    for scenario in load_scenarios()["scenarios"]:
        if scenario.get("implemented"):
            await run_scenario(scenario["id"], headed=headed)
