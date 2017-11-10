#!/usr/bin/env bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cp -f "$1" "${SCRIPT_DIR}/selenium-bravo-servlet.jar"
vagrant ssh selenium -- -C "echo BRAVOEXT_PATH=SNAPSHOT | sudo tee /opt/selenium/selenium_entry.cfg; sudo systemctl restart xpraonboot"
