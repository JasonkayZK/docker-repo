from pymilvus import MilvusClient

client = MilvusClient(
    uri='http://localhost:19530', # replace with your own Milvus server address
    token="root:Milvus"
)

client.update_password('root', 'Milvus', '<your-new-password>', using='default')

print(client.list_users())
