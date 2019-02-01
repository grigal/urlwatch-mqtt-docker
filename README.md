urlwatch-mqtt
========

Monitor webpages for updates and post to MQTT broker. Includes a custom `urlwatch` reporter hook for connecting and publishing to an MQTT broker (`hooks.py`).

* [urlwatch][1] is a tool for monitoring webpages for updates.
* [MQTT][2] is an ISO standard publish-subscribe-based messaging protocol.

This container is based on the [vimagick/dockerfiles](https://github.com/vimagick/dockerfiles) urlwatch container. 

```
cron: triggered every 15 minutes
    -> urlwatch: fetch webpages
        -> hooks.py: extract info
            -> publish updates to MQTT
                -> (^_^)
```

## urlwatch.yaml

Configure the [Paho MQTT publishier](https://pypi.org/project/paho-mqtt/) in `urlwatch.yaml`.

* `username` and `password` are optional. 
* `verbs` specify the urlwatch verbs that will cause a message to be published.
* `topic` is the base topic published to. The urlwatch rule name will be appended to this string.

```
...
report:
  mqtt:
    enabled: true
    server: mosquitto
    client_id: urlwatch
    username: mqtt_writer
    password: my_secret
    port: 1883
    topic: urlwatch/
    verbs:
      - new
      - changed
      - unchanged
      - error
...
```

## urls.yaml

```
kind: url
name: stephenhouser
url: https://stephenhouser.com
---
kind: url
name: urlwatch-mqtt-docker
url: "https://github.com/stephenhouser/urlwatch-mqtt-docker/releases/latest"
filter:
  - xpath: '(//div[contains(@class,"release-timeline-tags")]//h4)[1]/a'
  - html2text: re
```

[1]: http://thp.io/2008/urlwatch/
[2]: http://mqtt.org/
