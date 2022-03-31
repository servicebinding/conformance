import os


class Environment(object):
    cli = "kubectl"

    def __init__(self, cli):
        self.cli = cli


# This is a global context (complementing behave's context)
# to be accesible from any place, even where behave's context is not available.
ctx = Environment(os.getenv("TEST_ACCEPTANCE_CLI", "kubectl"))
