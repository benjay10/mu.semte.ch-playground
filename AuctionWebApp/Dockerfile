FROM archlinux:base-20210808.0.31089
#FROM ubuntu:impish-20210722

RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm nodejs
RUN pacman -S --noconfirm npm
RUN npm install -g ember-cli
RUN mkdir /webapp

ENTRYPOINT [ "sh", "-c", "cd /webapp && ember serve" ]

