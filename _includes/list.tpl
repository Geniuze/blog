{% include header.tpl %}

{% for post in list %}
<article{% if forloop.index == 1 and preview %} content-loaded="1"{% endif %}>
	<h2><a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></h2>
	{% include meta.tpl %}
	<div class="article-content">
	{% if forloop.index == 1 and preview and post.layout == 'post' %}
		{% if post.content contains "<!-- more -->" %}
			{{ post.content | split:"<!-- more -->" | first % }}
			<h4><a href='{{ site.baseurl }}{{ post.url }}' title='Read more...'>Read more...</a></h4>
		{% else %}
			{{ post.content }}
		{% endif %}
	{% endif %}
	</div>
</article>
{% endfor %}

{% if list == null %}
<article class="empty">
	<p>该分类下还没有文章</p>
</article>
{% endif %}
