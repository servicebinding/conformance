from environment import ctx
from command import Command
from behave import given
from util import substitute_scenario_id
import polling2

import os


class Namespace(object):
    def __init__(self, name):
        self.name = name
        self.cmd = Command()

    def create(self):
        output, exit_code = self.cmd.run(f"{ctx.cli} create namespace {self.name}")
        return exit_code == 0

    def is_present(self):
        _, exit_code = self.cmd.run(f'{ctx.cli} get ns {self.name}')
        return exit_code == 0


def namespace_maybe_create(context, namespace_name):
    namespace = Namespace(substitute_scenario_id(context, namespace_name))
    if not namespace.is_present():
        print("Namespace is not present, creating namespace: {}...".format(namespace_name))
        if not namespace.create():
            print(f"Unable to create namespace '{namespace_name}'")
            return None

    print("Namespace {} is created!!!".format(namespace_name))
    return namespace


def namespace_is_used(context, namespace_name):
    context.namespace = polling2.poll(lambda: namespace_maybe_create(context, namespace_name),
                                      step=1, timeout=30, check_success=lambda x: x is not None)


@given(u'Namespace [{namespace_env}] is used')
def given_namespace_from_env_is_used(context, namespace_env):
    env = os.getenv(namespace_env)
    assert env is not None, f"{namespace_env} environment variable needs to be set"
    print(f"{namespace_env} = {env}")
    namespace_is_used(context, env)
