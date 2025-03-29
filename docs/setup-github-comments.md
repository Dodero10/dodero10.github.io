# Setting Up GitHub Comments

This website uses [giscus](https://giscus.app/) for comments, which is powered by GitHub Discussions. Follow these steps to finish setting up comments on your website:

## 1. Enable Discussions in Your Repository

1. Go to your repository: https://github.com/dodero10/dodero10.github.io
2. Click on "Settings"
3. Scroll down to the "Features" section
4. Check the box next to "Discussions" to enable it
5. Click "Save"

## 2. Create a Discussion Category

1. Go to the "Discussions" tab in your repository
2. Click on "Categories" in the sidebar
3. Create a new category called "Comments" (or use an existing one like "Announcements")
4. Note the category ID (you'll need this for the configuration)

## 3. Get Your Repository ID

1. Go to https://giscus.app/
2. Enter your repository name: `dodero10/dodero10.github.io`
3. Choose your discussion category (the one you created or selected in step 2)
4. Choose "pathname" as the mapping
5. Copy the Repository ID and Category ID from the giscus configuration

## 4. Update Your Configuration

Update the giscus script in `overrides/main.html` with your:
- Repository ID (replace `YOUR_REPOSITORY_ID`)
- Category ID (replace `YOUR_CATEGORY_ID`)

```html
<script src="https://giscus.app/client.js"
        data-repo="dodero10/dodero10.github.io"
        data-repo-id="YOUR_REPOSITORY_ID"
        data-category="Comments" <!-- Or whatever category you created -->
        data-category-id="YOUR_CATEGORY_ID"
        data-mapping="pathname"
        data-strict="0"
        data-reactions-enabled="1"
        data-emit-metadata="0"
        data-input-position="bottom"
        data-theme="preferred_color_scheme"
        data-lang="en"
        crossorigin="anonymous"
        async>
</script>
```

## 5. Enable Comments on Individual Pages

To enable comments on a specific page, add the following metadata at the top of your Markdown file:

```yaml
---
comments: true
---
```

## 6. Deploy Your Site

After making these changes, rebuild and deploy your site. The comments section should now appear on pages where you've enabled comments.

## Troubleshooting

- Make sure GitHub Discussions is enabled for your repository
- Verify that the Repository ID and Category ID are correct
- Check that your pages have the `comments: true` metadata
- Ensure the user viewing the page is logged into GitHub (for posting comments) 