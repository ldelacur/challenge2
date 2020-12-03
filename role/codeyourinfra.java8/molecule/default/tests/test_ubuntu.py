import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('ubuntu')


def test_java8_is_installed(host):
    java8 = host.package("openjdk-8-jdk")
    assert java8.is_installed
    assert java8.version.startswith("8u")
