# Install Redis on Ubuntu


```bash
sudo apt-get install lsb-release curl gpg &&\
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg &&\
sudo chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg &&\
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list &&\
sudo apt-get update &&\
sudo apt-get install -y redis
```


# Install k6 Ubuntu
```bash
sudo gpg -k &&\
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69 &&\
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list &&\
sudo apt-get update &&\
sudo apt-get install -y k6
```
