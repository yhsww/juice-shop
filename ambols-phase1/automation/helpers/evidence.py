from datetime import datetime, timezone
from pathlib import Path
import json

def now():
    return datetime.now(timezone.utc).isoformat()

class EvidenceRecorder:
    def __init__(self, execution_dir, scenario):
        self.execution_dir = Path(execution_dir)
        self.execution_dir.mkdir(parents=True, exist_ok=True)
        self.scenario = scenario
        self.steps = []

    async def capture(self, page, step_id, action, data=None):
        screenshot = self.execution_dir / f"{step_id}.png"
        await page.screenshot(path=str(screenshot), full_page=True)
        self.steps.append({
            "step_id": step_id,
            "timestamp": now(),
            "action": action,
            "data_provided": data,
            "observed": {
                "url": page.url,
                "visible_text": (await page.locator("body").inner_text())[:20000]
            },
            "screenshot": screenshot.name
        })

    def finalize(self, status, note):
        result = {
            "scenario_id": self.scenario["id"],
            "domain": self.scenario["domain"],
            "name": self.scenario["name"],
            "status": status,
            "conclusion_note": note,
            "steps": self.steps,
            "generated_at": now()
        }
        (self.execution_dir / "execution.json").write_text(
            json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8"
        )
        return result
