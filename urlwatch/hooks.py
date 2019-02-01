import re

from urlwatch import filters
from urlwatch import jobs
from urlwatch import reporters

import json

from pprint import pprint
from time import time

import paho.mqtt.client as mqtt

class CustomMQTTReporter(reporters.TextReporter):
    """Custom reporter that writes the report to a MQTT Topic"""

    __kind__ = 'mqtt'

    def submit(self):
        cfg = self.report.config['report'][self.__kind__]

        server = cfg['server'] if 'server' in cfg else 'localhost'
        port = int(cfg['port']) if 'port' in cfg else 1883
        client_id = cfg['client_id'] if 'client_id' in cfg else None

        client = mqtt.Client(client_id=client_id)
        if 'username' in cfg and 'password' in cfg:
            client.username_pw_set(cfg['username'], cfg['password'])
        
        client.connect(server, port, 60)
        client.loop_start()

        topic_fmt = cfg['topic'] + '{}'
        trigger_verbs = cfg['verbs']

        for js in self.job_states:
            if js.verb in trigger_verbs:
                timestamp = js.timestamp if js.timestamp == 'null' else int(time())

                topic = topic_fmt.format(js.job.name)
                jdata = {
                    'timestamp': timestamp,
                    'name': js.job.name,
                    'url': js.job.url,
                    'verb': js.verb,
                }
                if js.old_data and len(js.old_data) < 80:
                    #print(f'"old_data":"{js.old_data}"', end=",")
                    jdata['old_data'] = js.old_data
                if js.new_data and len(js.new_data) < 80:
                    #print(f'"new_data":"{js.new_data}"', end=" ")
                    jdata['new_data'] = js.new_data

                #print(topic, end=": ")
                #print(json.dumps(jdata))
                client.publish(topic, json.dumps(jdata))
