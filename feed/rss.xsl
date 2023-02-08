<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
    <xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:template match="/">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <title><xsl:value-of select="/rss/channel/title"/> RSS Feed</title>
                <meta charset="UTF-8" />
                <meta http-equiv="x-ua-compatible" content="IE=edge,chrome=1" />
                <meta name="viewport" content="width=device-width,minimum-scale=1,initial-scale=1,shrink-to-fit=no" />
		<link rel="alternate" type="application/rss+xml" title="RSS" href="mahlzeit.rss" />
                <style type="text/css">
                    /* Your custom styles can go here! */
                </style>
            </head>
            <body>
                <header>
                    <h1>
                        <xsl:value-of select="/rss/channel/title"/>
                    </h1>
                    <p>
                        <xsl:value-of select="/rss/channel/description"/>
                    </p>
                </header>
                <main>
                    <h2>Recent Menu</h2>
   <xsl:for-each select="rss/channel/item">
         <tr style="color:#0080FF;">
              <td style="text-align:left;font-weight:bold;">
                   <xsl:value-of select="title"></xsl:value-of>
              </td>
              <td style="text-align:right;font-weight:bold;">
                   Updated: <xsl:value-of select="pubDate" />
              </td>
         </tr>
         <tr>
              <td colspan="2" style="text-align:left;padding-top:10px;">
                   <xsl:value-of select="description" disable-output-escaping="yes" />
              </td>
         </tr>
         <tr>
              <td colspan="2" style="height:20px;">
                   <hr>
                   </hr>
              </td>
         </tr>
    </xsl:for-each>
                </main>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>

