from cluster import Cluster
from command import Command
from environment import ctx
from behave import step
from util import substitute_scenario_id
import polling2
import json


class App(object):
    cluster = Cluster()
    cmd = Command()
    name = ""
    namespace = ""
    app_image = ""
    route_url = ""
    port = ""
    bindingRoot = ""
    resource = ""

    def __init__(self, name, namespace, app_image, port="", resource="deployment"):
        self.name = name
        self.namespace = namespace
        self.app_image = app_image
        self.port = port
        self.resource = resource

    def is_running(self, wait=False):
        output, exit_code = self.cmd.run(
            f"{ctx.cli} wait --for=condition=Available=True {self.resource}/{self.name} -n {self.namespace} --timeout={300 if wait else 0}s")
        running = exit_code == 0
        if running:
            self.route_url = polling2.poll(lambda: self.base_url(),
                                           check_success=lambda v: v != "", step=1, timeout=100)
        return running

    def install(self, bindingRoot=None):
        self.cluster.new_app(self.name, self.app_image, self.namespace, bindingRoot, self.resource == "deploymentconfig")
        self.cluster.expose_service_route(self.name, self.namespace, self.port)
        return self.is_running(wait=True)

    def base_url(self):
        return self.cluster.get_route_host(self.name, self.namespace)

    def get_generation(self):
        deployment_name = self.cluster.get_deployment_name_in_namespace(
                            self.format_pattern(self.deployment_name_pattern), self.namespace, resource=self.resource)
        return int(self.cluster.get_resource_info_by_jsonpath(self.resource, deployment_name, self.namespace, "{.metadata.generation}"))
