# backend-solver-julia

Server that solves ODE problems.

## Run 
```bash
julia src/app.jl
```

## Usage
```bash
# bash

curl http://127.0.0.1:2021/get

curl -d '{"model": "BR"}' http://127.0.0.1:2021/get_model_states_params

curl -d '{"model": "BR"}' http://127.0.0.1:2021/solve_cellml_model > sol.json

```

```python
# python

requests.post("http://127.0.0.1:2021/solve_cellml_model", json={"model": "BR"})
```
