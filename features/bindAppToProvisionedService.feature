Feature: Bind workload to provisioned service

  As a user I would like to bind my applications to provisioned services, as defined by the binding spec

  Scenario: SPEC Bind workload to provisioned service
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
                type: db
            """
    And CRD "provisioned_backend" is available
    And The Custom Resource is present
            """
            apiVersion: stable.example.com/v1
            kind: ProvisionedBackend
            metadata:
                name: $scenario_id
            spec:
                foo: bar
            status:
                binding:
                    name: $scenario_id
            """
    And Generic test application is running
    When Service Binding is applied
          """
          apiVersion: servicebinding.io/v1alpha3
          kind: ServiceBinding
          metadata:
              name: $scenario_id
          spec:
              service:
                apiVersion: stable.example.com/v1
                kind: ProvisionedBackend
                name: $scenario_id
              workload:
                name: $scenario_id
                apiVersion: apps/v1
                kind: Deployment
          """
    Then Service Binding becomes ready
    And jq ".status.binding.name" of Service Binding should be changed to "$scenario_id"
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
            db
            """
