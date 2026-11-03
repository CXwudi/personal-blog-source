# About this blog

Choose a Language/选择语言: English ver (Current), [中文版](./README.zh-cn.md)

This is the source configuration of the blog hosted on https://blog.mikufancx.cyou

In case of the domain is changing, you can visit the alternative URL at https://mikufancx-blog.vercel.app/ 

## Develop/Test the blog

Run `mise run dev` to preview the blog locally.

Alternatively, use `mise run dev --prod` to enable commenting system in local preview.

## Publish the blog

Run `mise run generate --prod` to generate the static HTML files of the blog in the `./public` folder (or `mise run generate` to include drafts for local/test builds).
