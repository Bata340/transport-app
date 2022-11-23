# tdl_transporte_divs_centrados

Proyecto de visualización de transportes públicos en tiempo real. Teoría de Lenguaje. Divs Centrados.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

##How to run python to use with flutter?

You have to run the server with uvicorn:

```shell
cd fastapideta/transport-app-api
pip install -r requirements.txt
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Afterwards it is needed to publish the local address as public with a tool such as ngrok:

dashboard.ngrok.com

Where you may use the following command after creating an account with ngrok's shell:

```shell
ngrok http 8000
```

Then you may update the .env of the flutter app and afterwards compile and test it.
This is obviously because the url changes every time we run ngrok. The forwarding
URL is the one you may use to do your testing.
