from app import App
import requests
import json
import polling2
from behave import step
from util import substitute_scenario_id
from string import Template


class GenericTestApp(App):

    deployment_name_pattern = "{name}"

    def __init__(self, name, namespace, app_image="ghcr.io/servicebinding/generic-test-app"):
        App.__init__(self, name, namespace, app_image, "8080")

    def format_pattern(self, pattern):
        return pattern.format(name=self.name)

    def get_file_value(self, file_path):
        resp = polling2.poll(lambda: requests.get(url=f"http://{self.route_url}{file_path}"),
                             check_success=lambda r: r.status_code == 200, step=5, timeout=400, ignore_exceptions=(requests.exceptions.ConnectionError,))
        print(f'file endpoint response: {resp.text} code: {resp.status_code}')
        return resp.text

    def set_label(self, label):
        self.kubernetes.set_label(self.name, label, self.namespace)


@step(u'Generic test application is running')
def is_running(context):
    application_name = substitute_scenario_id(context)
    application = GenericTestApp(application_name, context.namespace.name)
    if not application.is_running():
        print("application is not running, trying to import it")
        application.install()
    context.application = application

@step(u'Content of file "{file_path}" in workload pod is')
def check_file_value(context, file_path):
    value = Template(context.text.strip()).substitute(NAMESPACE=context.namespace.name)
    resource = substitute_scenario_id(context, file_path)
    polling2.poll(lambda: context.application.get_file_value(resource) == value, step=5, timeout=400)
