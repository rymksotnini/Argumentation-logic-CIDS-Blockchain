FROM ubuntu:xenial
RUN apt-get update && apt-get install -y wget software-properties-common && rm -rf /var/lib/apt/lists/*
WORKDIR "/root"
RUN add-apt-repository -y ppa:ethereum/ethereum
RUN apt-get update && apt-get install -y ethereum
ARG pwd
ARG pk
ADD ./application-5-nodes.json ./application-5-nodes.json
RUN geth --datadir ~/sealer init ./application-5-nodes.json
RUN echo $pwd > `mktemp /tmp/.pwd.XXX`
RUN echo $pk > `mktemp /tmp/.pk.XXX`
RUN geth --datadir ~/sealer account import --password /tmp/`ls -al /tmp/ | awk '{print $9}' | grep .pwd` /tmp/`ls -al /tmp/ | awk '{print $9}' | grep .pk`
ENV addr=""
ENV id=""
ENV ip=""
CMD exec geth --bootnodes "enode://$id@$ip:30301"  --allow-insecure-unlock --datadir ~/sealer --networkid 6085214 --verbosity=4 --http   --http.addr  "0.0.0.0" --http.port "59767" --http.api="eth,net,web3,personal,web3,miner"  --http.corsdomain "*" --syncmode=full --mine -miner.gasprice=0 -miner.threads=1 --miner.etherbase $addr --unlock $addr --password /tmp/`ls -al /tmp/ | awk '{print $9}' | grep .pwd`
EXPOSE 30303
EXPOSE 59767