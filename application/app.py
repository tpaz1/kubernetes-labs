from flask import Flask, render_template_string
import os

app = Flask(__name__)

@app.route('/')
def home():
    color = os.getenv('UI_COLOR', 'white')  # Default color is white
    html = f"""
    <!doctype html>
    <html>
        <head><title>Hello Kubernetes technion course!</title></head>
        <body style="background-color: {color};">
            <h1 style="color: black;">Hello, Kubernetes!</h1>
            <p>The background color is {color}.</p>
        </body>
    </html>
    """
    return render_template_string(html)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)