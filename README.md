# Monitor

## Introduction

An Example Elixir/Phoenix Application to illustrate:

* How an Elixir application fits with the Phoenix Web Components.
* How to setup non-trivial Elixir Supervisors
* Using Phoenix Channels to dynamically update a client

## Overview

`Monitor` is an example of a web site monitoring tool. It can be used
to monitor server heat-beat as well as a number of web servers residing
on a physical web server.

### Definitions

Monitor - The Elixir Application
Server - A physical server that registers with the Monitor
Service - A web server application residing on a Server

## Design

### Elixir Projects

Monitor - The main Monitor Project
Service - A simple Phoneix project simulating a web site
MonitorServer - The Elixir client running on the server to be monitored

### Workflow

* Use the Monitor GUI to configure a Server and a number of Services.
* The MonitorServer is configured with the id of the Server record configured in the Monitor GUI
* Each Service to be monitored is provisioned with its request url and expected response. Each `Service` is started on the server.




