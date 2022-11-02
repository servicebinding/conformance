Feature: Bind workloads matching a label selector to a service

    As a user, I want to bind workloads that match a particular label selector

    Background:
        Given Namespace [TEST_NAMESPACE] is used
        And The Secret is present
            """
            apiVersion: v1
            kind: Secret
            metadata:
                name: $scenario_id
            stringData:
                username: foo
                password: bar
                type: baz
            """

    Scenario: Bind a workload matching a label selector to a service
        Given Generic test application is running with binding root as "/bindings" and labeled as "app-custom=$scenario_id"
        When Service Binding is applied
            """
            apiVersion: servicebinding.io/v1beta1
            kind: ServiceBinding
            metadata:
                name: $scenario_id
            spec:
                service:
                    apiVersion: v1
                    kind: Secret
                    name: $scenario_id
                workload:
                    apiVersion: apps/v1
                    kind: Deployment
                    selector:
                        matchLabels:
                            app-custom: $scenario_id
            """
        Then Service Binding becomes ready
        And Content of file "/bindings/$scenario_id/username" in workload pod is
            """
            foo
            """
        And Content of file "/bindings/$scenario_id/password" in workload pod is
            """
            bar
            """
        And Content of file "/bindings/$scenario_id/type" in workload pod is
            """
            baz
            """

    Scenario: Bind two workloads to a single service
        Given Generic test application "$scenario_id-1" is running with binding root as "/bindings" and labeled as "app-custom=$scenario_id"
        Given Generic test application "$scenario_id-2" is running with binding root as "/bindings" and labeled as "app-custom=$scenario_id"
        When Service Binding is applied
            """
            apiVersion: servicebinding.io/v1beta1
            kind: ServiceBinding
            metadata:
                name: $scenario_id
            spec:
                service:
                    apiVersion: v1
                    kind: Secret
                    name: $scenario_id
                workload:
                    apiVersion: apps/v1
                    kind: Deployment
                    selector:
                        matchLabels:
                            app-custom: $scenario_id
            """
        Then Service Binding becomes ready
        And Content of file "/bindings/$scenario_id/username" in workload pod "$scenario_id-1" is
            """
            foo
            """
        And Content of file "/bindings/$scenario_id/password" in workload pod "$scenario_id-1" is
            """
            bar
            """
        And Content of file "/bindings/$scenario_id/type" in workload pod "$scenario_id-1" is
            """
            baz
            """
        And Content of file "/bindings/$scenario_id/username" in workload pod "$scenario_id-2" is
            """
            foo
            """
        And Content of file "/bindings/$scenario_id/password" in workload pod "$scenario_id-2" is
            """
            bar
            """
        And Content of file "/bindings/$scenario_id/type" in workload pod "$scenario_id-2" is
            """
            baz
            """

    Scenario: Bind a labeled workload submitted after the service binding
        Given Service Binding is applied
            """
            apiVersion: servicebinding.io/v1beta1
            kind: ServiceBinding
            metadata:
                name: $scenario_id
            spec:
                service:
                    apiVersion: v1
                    kind: Secret
                    name: $scenario_id
                workload:
                    apiVersion: apps/v1
                    kind: Deployment
                    selector:
                        matchLabels:
                            app-custom: $scenario_id
            """
        When Generic test application is running with binding root as "/bindings" and labeled as "app-custom=$scenario_id"
        Then Service Binding becomes ready
        And Content of file "/bindings/$scenario_id/username" in workload pod is
            """
            foo
            """
        And Content of file "/bindings/$scenario_id/password" in workload pod is
            """
            bar
            """
        And Content of file "/bindings/$scenario_id/type" in workload pod is
            """
            baz
            """

    Scenario: Bind labeled workloads with a already successful service binding
        Given Generic test application "$scenario_id-1" is running with binding root as "/bindings" and labeled as "app-custom=$scenario_id"
        And Service Binding is applied
            """
            apiVersion: servicebinding.io/v1beta1
            kind: ServiceBinding
            metadata:
                name: $scenario_id
            spec:
                service:
                    apiVersion: v1
                    kind: Secret
                    name: $scenario_id
                workload:
                    apiVersion: apps/v1
                    kind: Deployment
                    selector:
                        matchLabels:
                            app-custom: $scenario_id
            """
        And Service Binding becomes ready
        When Generic test application "$scenario_id-2" is running with binding root as "/bindings" and labeled as "app-custom=$scenario_id"
        Then Service Binding becomes ready
        And Content of file "/bindings/$scenario_id/username" in workload pod "$scenario_id-1" is
            """
            foo
            """
        And Content of file "/bindings/$scenario_id/password" in workload pod "$scenario_id-1" is
            """
            bar
            """
        And Content of file "/bindings/$scenario_id/type" in workload pod "$scenario_id-1" is
            """
            baz
            """
        And Content of file "/bindings/$scenario_id/username" in workload pod "$scenario_id-2" is
            """
            foo
            """
        And Content of file "/bindings/$scenario_id/password" in workload pod "$scenario_id-2" is
            """
            bar
            """
        And Content of file "/bindings/$scenario_id/type" in workload pod "$scenario_id-2" is
            """
            baz
            """

    Scenario: Changing a workload's label unbinds the service
        Given Generic test application is running with binding root as "/bindings" and labeled as "app-custom=$scenario_id-1"
        And Service Binding is applied
            """
            apiVersion: servicebinding.io/v1beta1
            kind: ServiceBinding
            metadata:
                name: $scenario_id
            spec:
                service:
                    apiVersion: v1
                    kind: Secret
                    name: $scenario_id
                workload:
                    apiVersion: apps/v1
                    kind: Deployment
                    selector:
                        matchLabels:
                            app-custom: $scenario_id-1
            """
        And Service Binding becomes ready
        And Content of file "/bindings/$scenario_id/username" in workload pod is
            """
            foo
            """
        And Content of file "/bindings/$scenario_id/password" in workload pod is
            """
            bar
            """
        And Content of file "/bindings/$scenario_id/type" in workload pod is
            """
            baz
            """
        When Generic test application is running with binding root as "/bindings" and labeled as "app-custom=$scenario_id-2"
        Then File "/bindings/$scenario_id/username" is unavailable in workload pod
        And  File "/bindings/$scenario_id/password" is unavailable in workload pod
        And  File "/bindings/$scenario_id/type" is unavailable in workload pod
