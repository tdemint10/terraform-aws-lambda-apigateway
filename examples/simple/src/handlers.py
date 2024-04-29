def handle(event: dict, _: object) -> str:
    """Do a thing."""
    print(f"Received event: {event}")
    return "Hello, World!"
