#!/bin/bash

ntpd

ubusd &

sysmngr -l 7 &

wifidmd -l 7 &

ethmngr -l 7 &

timemngr -l 7 &

dm-service -m core &

dm-service -m netmngr &

sleep 3

bbfdmd -l 7 &

sleep 3

icwmpd --boot-event
