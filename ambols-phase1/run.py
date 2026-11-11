import argparse
import asyncio
from automation.runner import run_all, run_scenario, check_environment

def main():
    parser = argparse.ArgumentParser(description="AMBOLS Juice Shop - Fase 1")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--check", action="store_true")
    group.add_argument("--all", action="store_true")
    group.add_argument("--scenario")
    parser.add_argument("--headed", action="store_true")
    args = parser.parse_args()
    if args.check:
        raise SystemExit(check_environment())
    if args.scenario:
        asyncio.run(run_scenario(args.scenario, headed=args.headed))
    else:
        asyncio.run(run_all(headed=args.headed))

if __name__ == "__main__":
    main()
