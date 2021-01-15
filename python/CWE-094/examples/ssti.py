import os

from flask import Flask, request, escape, render_template_string
from jinja2 import Environment, PackageLoader, select_autoescape


app = Flask(__name__)
app.config["SECRET_KEY"] = "SuperSecretKeyForEverything"
env = Environment(
    loader=PackageLoader(__name__, os.path.abspath('templates')),
    autoescape=select_autoescape(['html', 'xml'])
)


@app.route("/ssti1")
def ssti1():
    search = request.args.get("search")
    # SECURITY: Template string can be used
    return render_template_string("<h2>Search Results: " + search + "</h2>")


@app.route("/ssti2")
def ssti2():
    search = request.args.get("search")
    # SECURITY: Using HTML escaping doesn't work in this context
    return render_template_string("<h2>Search Results: " + escape(search) + "</h2>")


@app.route("/ssti3")
def ssti3():
    search = request.args.get("search")
    # SECURITY: Using HTML escaping doesn't work in this context
    return env.from_string("<h2>Search Results: " + search + "</h2>").render()


# Run app
app.run("0.0.0.0", port=5000)
