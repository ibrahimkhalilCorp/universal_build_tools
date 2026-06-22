# Prompt: Abstract Design Phase (Universal)

> Inherit `_base.md`. Read `PROJECT.config.md` first.
> তুমি এখন senior engineer। Implementation এর আগে সব abstract class/interface design করো।
> এই phase এ কোনো concrete implementation logic নয়।

## Step 1 — Context
`PROJECT.config.md` + `docs/architecture.md` + `.tracker/progress.md`।

## Step 2 — প্রতি major component এ abstract class
```
from abc import ABC, abstractmethod
class BaseXxx(ABC):
    """
    One-line purpose.
    Responsibilities:
      - ...
    Does NOT handle:
      - ...
    """
    @abstractmethod
    def method(self, ...) -> ...: ...
```
- `{{NAMING}}` follow করো।
- `{{STRUCTURE_RULES}}` অনুযায়ী file location ঠিক করো।
- `{{DOMAIN_RULES}}` যেগুলো interface-level constraint, signature/docstring এ encode করো।

## Step 3 — Output
প্রতি module এ `schemas` (data shapes) + base interfaces। কোনো business logic নয়।
একবারে এক component। Tracker update। STOP।
