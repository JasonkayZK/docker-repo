docker run -itd  --restart=always --name=my-picimpact  -p 13000:3000  -e DATABASE_URL="postgres://user:password@ip:port/postgres"  -e AUTH_SECRET="your-password"  besscroft/picimpact:latest
