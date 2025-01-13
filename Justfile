default: format check test

format:
    roc format src/
    roc format examples/

check:
    roc check src/main.roc

test:
    roc test src/main.roc

docs:
    roc docs src/main.roc

ratchet:
    ratchet upgrade .github/workflows/*.yaml
