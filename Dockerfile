FROM dhi.io/python:3.14-dev AS base
LABEL maintainer="Eko Junaidi Salam <eko.junaidi.salam@gmail.com>"

WORKDIR /app

RUN pip install uv
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/app/.venv

RUN uv init
RUN uv add "fastapi[standard]"

FROM base AS working

WORKDIR /app

COPY --from=base /app/.venv /app/.venv
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/app/.venv \
    PATH="/app/.venv/bin:$PATH"

COPY --from=base /app/pyproject.toml /app/pyproject.toml
COPY src /app/src

FROM dhi.io/python:3.14 AS runtime

WORKDIR /app

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/app/.venv/bin:$PATH"

COPY --from=working /app/.venv /app/.venv
COPY --from=working /app/src /app/src

CMD ["fastapi", "run", "src/app/main.py"]