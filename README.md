# Conformance testing

This repository contains conformance tests for implementations of [the service binding specification][spec].

# Running tests

First, you'll need to set up the testing environment.  This can be done by
running `./setup.sh`, which will pull the necessary dependencies.

Next, make sure your implementation of the specification is available on your
kubernetes cluster.  At the very least, you need to be serving
`ServiceBindings` under the `servicebinding.io` namespace.  Your cluster will
need to be available as the default context within `kubectl`.

Once you've done that, you can invoke the test runner:
```bash
./run_tests.sh
```

## Test runner arguments

The `./run_tests.sh` script accepts a few arguments, which can help test in certain environments:

- `-j N`: runs acceptance tests with `N` runners.  Since this runs tests in
  parallel without any namespace isolation, this can cause test instability in
  some implementations.  If you see spurious failures, try testing with this
  flag unset.  Defaults to 1.
- `-n NAMESPACE`: run acceptance tests in `NAMESPACE`.  Defaults to
  `servicebindings-cts`, which will be created if it doesn't exist.

[spec]: https://github.com/servicebindings/spec
