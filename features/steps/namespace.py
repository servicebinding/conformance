from environment import ctx
from command import Command
from behave import given
from util import substitute_scenario_id

import os


class Namespace(object):
    def __init__(self, name):
        self.name = name
        self.cmd = Command()

    def create(self):
        output, exit_code = self.cmd.run(f"{ctx.cli} create namespace {self.name}")
        assert exit_code == 0, f"Unexpected output when creating namespace: '{output}'"
        return True

    def is_present(self):
        _, exit_code = self.cmd.run(f'{ctx.cli} get ns {self.name}')
        return exit_code == 0


def namespace_maybe_create(context, namespace_name):
    namespace = Namespace(substitute_scenario_id(context, namespace_name))
    if not namespace.is_present():
        print("Namespace is not present, creating namespace: {}...".format(namespace_name))
        assert namespace.create(), f"Unable to create namespace '{namespace_name}'"
    print("Namespace {} is created!!!".format(namespace_name))
    return namespace


def namespace_is_used(context, namespace_name):
    context.namespace = namespace_maybe_create(context, namespace_name)


@given(u'Namespace [{namespace_env}] is used')
def given_namespace_from_env_is_used(context, namespace_env):
    env = os.getenv(namespace_env)
    assert env is not None, f"{namespace_env} environment variable needs to be set"
    print(f"{namespace_env} = {env}")
    namespace_is_used(context, env)
