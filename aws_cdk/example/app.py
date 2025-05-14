#!/usr/bin/env python3
import os

import aws_cdk as cdk

from example.example_stack import ExampleStack


app = cdk.App()
ExampleStack(app, "iac-cdk-test")

app.synth()