import subprocess
import os


class Command(object):
    path = ""
    env = {}

    def __init__(self, path=None):
        if path is None:
            self.path = os.getcwd()
        else:
            self.path = path

        kubeconfig = os.getenv("KUBECONFIG")
        if kubeconfig is None:
            kubeconfig = f"{os.path.expanduser('~')}/.kube/config"
        available = os.path.isfile(kubeconfig)
        assert available, "Unable to find current kubernetes context!"
        self.setenv("KUBECONFIG", kubeconfig)

        path = os.getenv("PATH")
        assert path is not None, "PATH needs to be set in the environment"
        self.setenv("PATH", path)

    def setenv(self, key, value):
        assert key is not None and value is not None, \
            f"Name or value of the environment variable cannot be None: [{key} = {value}]"
        self.env[key] = value

    def run(self, cmd, stdin=None):
        print(f",---------,-\n| COMMAND : {cmd}\n'---------'-")  # for debugging purposes
        output = None
        exit_code = 0
        try:
            if stdin is None:
                output = subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT, cwd=self.path, env=self.env)
            else:
                output = subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT, cwd=self.path,
                                                 env=self.env, input=stdin.encode("utf-8"))
        except subprocess.CalledProcessError as err:
            output = err.output
            exit_code = err.returncode
            print('ERROR MESSGE:', output)
            print('ERROR CODE:', exit_code)
        return output.decode("utf-8"), exit_code
