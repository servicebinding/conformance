from app import App
import requests
import json
import polling2
from behave import step, then
from util import substitute_scenario_id
from string import Template


class GenericTestApp(App):

    deployment_name_pattern = "{name}"

    def __init__(self, name, namespace, app_image="ghcr.io/servicebinding/conformance/generic-test-app:main"):
        super().__init__(name, namespace, app_image, "8080")

    def get_env_var_value(self, name):
        resp = polling2.poll(lambda: requests.get(url=f"http://{self.route_url}/env/{name}"),
                             check_success=lambda r: r.status_code in [200, 404],
                             step=5, timeout=400, ignore_exceptions=(requests.exceptions.ConnectionError,))
        print(f'env endpoint response: {resp.text} code: {resp.status_code}')
        if resp.status_code == 200:
            return json.loads(resp.text)
        else:
            return None

    def assert_file_not_exist(self, file_path):
        polling2.poll(lambda: requests.get(url=f"http://{self.route_url}{file_path}"),
                      check_success=lambda r: r.status_code == 404, step=5, timeout=400,
                      ignore_exceptions=(requests.exceptions.ConnectionError,))

    def format_pattern(self, pattern):
        return pattern.format(name=self.name)

    def get_file_value(self, file_path):
        resp = polling2.poll(lambda: requests.get(url=f"http://{self.route_url}{file_path}"),
                             check_success=lambda r: r.status_code == 200, step=5,
                             timeout=400, ignore_exceptions=(requests.exceptions.ConnectionError,))
        print(f'file endpoint response: {resp.text} code: {resp.status_code}')
        return resp.text

    def set_label(self, label):
        self.cluster.set_label(self.name, label, self.namespace)


@step(u'Generic test application is running')
@step(u'Generic test application is running with binding root as "{bindingRoot}"')
@step(u'Generic test application is running with binding root as "{bindingRoot}" and labeled as "{label}"')
@step(u'Generic test application "{name}" is running with binding root as "{bindingRoot}" and labeled as "{label}"')
def is_running(context, name=None, bindingRoot=None, label=None):
    if name is None:
        application_name = substitute_scenario_id(context)
    else:
        application_name = substitute_scenario_id(context, name)
    application = GenericTestApp(application_name, context.namespace.name)
    print(f'application name: {application_name}')
    print(f'{application.name}')
    if not application.is_running():
        print("application is not running, trying to import it")
        application.install(bindingRoot=bindingRoot)
    if label is not None:
        label = substitute_scenario_id(context, label)
        application.set_label(label)
    context.workload = application
    context.workloads[application_name] = application


@step(u'Content of file "{file_path}" in workload pod is')
@step(u'Content of file "{file_path}" in workload pod "{name}" is')
def check_file_value(context, file_path, name=None):
    print(f'known workloads: {context.workloads}')
    workload = context.workload
    if name is not None:
        name = substitute_scenario_id(context, name)
        print(f'using workload "{name}"')
        workload = context.workloads[name]
    value = Template(context.text.strip()).substitute(NAMESPACE=context.namespace.name)
    resource = substitute_scenario_id(context, file_path)
    polling2.poll(lambda: workload.get_file_value(resource) == value, step=5, timeout=400)


@step(u'File "{file_path}" is unavailable in workload pod')
def check_file_unavailable(context, file_path):
    file_path = substitute_scenario_id(context, file_path)
    context.workload.assert_file_not_exist(file_path)


@step(u'The application env var "{name}" has value "{value}"')
def check_env_var_value(context, name, value=None):
    value = substitute_scenario_id(context, value)
    found = polling2.poll(lambda: context.workload.get_env_var_value(name) == value, step=5, timeout=400)
    assert found, f'Env var "{name}" should contain value "{value}"'


@step(u'The service binding root is valid')
def check_binding_root(context, name="SERVICE_BINDING_ROOT"):
    # TODO: check that this is a valid path within the container
    # for now, assert a non-zero-length string
    found = polling2.poll(lambda: context.workload.get_env_var_value(name), step=5, timeout=400)
    assert len(found) != 0, f'Env var "{name}" should be set'


@then(u'The projected binding "{binding_name}" has "{key}" set to')
def check_binding_value(context, binding_name, key):
    binding_root = polling2.poll(lambda: context.workload.get_env_var_value("SERVICE_BINDING_ROOT"),
                                 step=5, timeout=400)
    binding_path = binding_root + '/' + substitute_scenario_id(context, binding_name) + '/' + key
    check_file_value(context, binding_path)
