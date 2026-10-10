# nvidia-kaggle plugin: known failures and workarounds

Checked against plugin cache version `2b78cf29f5f3`
(`~/.claude/plugins/cache/nvidia-kaggle/nvidia-kaggle/<version>/`). Scripts live under
`skills/nvidia-kaggle-skill/scripts/`. Apply an entry only when its symptom appears. When the plugin
updates, rerun the plain script first and delete the entries it no longer needs.

## discussion_ingest.py returns one thread, or far fewer than the forum shows

Cause: `DiscussionClient._resolve_competition_title` (in `discussions/discussion_client.py`) resolves
the slug to the wrong competition title, and the Search API matches on titles.

Workaround: patch the method to return the title as the forum shows it, and run the script through
`runpy` from the competition repository:

```sh
K=~/.claude/plugins/cache/nvidia-kaggle/nvidia-kaggle/<version>/skills/nvidia-kaggle-skill/scripts
uv run --with httpx --with pydantic --with python-dotenv --with rich python - <<PY
import runpy, sys
sys.path.insert(0, "$K")
from discussions.discussion_client import DiscussionClient
DiscussionClient._resolve_competition_title = lambda self, slug: "<competition title>"
sys.argv = ["discussion_ingest.py", "<comp>"]
runpy.run_path("$K/discussion_ingest.py", run_name="__main__")
PY
```

The database that keeps the full history is the plugin's `data/discussions.db`, not the repository's
`data/`.

## fetch_top_kernel_scores.py fails with 401

Cause: it calls an old kernels list endpoint.

Workaround: list the refs with the Kaggle CLI, then fetch the score one ref at a time:

```sh
uv run kaggle kernels list --competition <comp> --sort-by dateCreated --page-size 100 -v
uv run kaggle kernels list --competition <comp> --sort-by voteCount --page-size 100 -v
# refs in a file, one per line
xargs -P 8 -I{} uv run --with httpx --with pydantic --with python-dotenv --with rich \
  python "$K/fetch_kernel_score.py" {} < .tmp/kernel_refs.txt
```

## Pulled notebooks have no outputs

`kaggle kernels pull -m` returns the source and metadata only. A score or a printed table has to come
from the API or from the kernel's text.
