from pathlib import Path

def generate_markdown(result, output_path):
    lines = [
        f"# {result['scenario_id']} — {result['name']}",
        "",
        f"Domínio: {result['domain']}",
        f"Status da execução: {result['status']}",
        "",
        "## Conclusão da execução",
        "",
        result["conclusion_note"],
        "",
        "## Evidências",
        ""
    ]
    for step in result["steps"]:
        lines += [
            f"### {step['step_id']}",
            "",
            f"Ação: {step['action']}",
            "",
            f"Dados fornecidos: {step['data_provided']}",
            "",
            f"URL observada: {step['observed']['url']}",
            "",
            "Texto visível registrado:",
            "",
            step["observed"]["visible_text"],
            "",
            f"Screenshot: {step['screenshot']}",
            ""
        ]
    Path(output_path).write_text("\n".join(lines), encoding="utf-8")
