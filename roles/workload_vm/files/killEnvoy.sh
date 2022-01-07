#!/bin/bash
sudo lsof -P -i | awk '/envoy/{print $2}' | xargs sudo kill || true
