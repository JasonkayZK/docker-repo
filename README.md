## Milvus Standalone

Use docker-compose way to deploy [milvus](https://github.com/milvus-io/milvus) standalone.

>   Reference: 
>
>   -   https://milvus.io/docs/install_standalone-docker-compose.md

Just run:

```bash
docker-compose up -d
```

Will start milvus within seconds!

<br/>

## Change Password

After deployment you can use a client that created by python to change the root password:

```bash
pip3 install pymilvus
```

Change python file:

```python
from pymilvus import MilvusClient

client = MilvusClient(
    uri='http://localhost:19530', # replace with your own Milvus server address
    token="root:Milvus"
)

client.update_password('root', 'Milvus', '<your-new-password>', using='default')

print(client.list_users())
```

And run.

>   Reference:
>
>   -   https://www.milvus-io.com/adminGuide/authenticate

<br/>

## Notice

When running standalone version the Milvus WebUI will show etcd Unhealthy.

You can just ignore this error, since you are using standalone etcd and there is only one node.

>   Reference:
>
>   -   https://github.com/milvus-io/milvus/issues/39417

