local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node
local f = ls.function_node
local sn = ls.snippet_node

local date_input = function(args, state, fmt)
    local fmt = fmt or "%Y-%m-%d"
    local f = io.popen("date +'" .. fmt .. "'", "r")
    return sn(nil, i(1, string.gsub(f:read(), "\n", "")))
end

ls.snippets = {
    post = {
        s({ trig = "post", dscr = "Post header" }, {
            i(1, "Title"),
            t({ "", "meta: date=" }), d(2, date_input, {}, "%Y-%m-%d %H:%M:%S"),
            t({ "", "meta: tags=" }), i(3),
            t({ "", "", "<short>", "" }), i(4),
            t({ "", "</short>", "", "" }), i(0),
        }),

        s({ trig = "pimg", dscr = "Image post" }, {
            i(1, "Title"),
            t({ "", "meta: img=" }), i(2),
            t({ "", "meta: alt=" }), i(3),
            t({ "", "" }), i(0),
        }),

        s({ trig = "meta", dscr = "Post metadata" }, {
            t({ "meta: date=" }), d(1, date_input, {}, "%Y-%m-%d %H:%M:%S"),
            t({ "", "meta: tags=" }), i(2),
            t({ "", "" }), i(0),
        }),

        s({ trig = "short", dscr = "Post summary" }, {
            t({ "<short>", "" }), i(1),
            t({ "", "</short>", "" }), i(0),
        }),

        ls.parser.parse_snippet("h2", "<h2>$1</h2>\n\n$0"),

        ls.parser.parse_snippet("h3", "<h3>$1</h3>\n\n$0"),

        ls.parser.parse_snippet(
            { trig = "a", dscr = "Link" },
            "<a href=\"$1\">$2</a>$0"
        ),

        s({ trig = "psumm", dscr = "Abstract" }, {
            t({ "<p class=p-summary property=abstract>", "" }),
        }),

        s({ trig = "au", dscr = "Link to selected URL" }, {
            t("<a href=\""),
            f(function (args) return string.gsub(args[1].env.TM_SELECTED_TEXT[1], "\n", "") end, {}),
            t("\">"), i(1),
            t("</a>"), i(0),
        }),

        s({ trig = "at", dscr = "Link from selected text" }, {
            t("<a href=\""), i(1),
            t("\">"), i(2),
            f(function (args) return string.gsub(args[1].env.TM_SELECTED_TEXT[1], "\n*$", "") end, {}),
            t("</a>"), i(0),
        }),

        s({ trig = "exc", dscr = "Excerpt" }, {
            t({ "<pre class=excerpt>" }), i(1),
            t({ "", "", "</pre>", "", "" }), i(0),
        }),

        s({ trig = "code", dscr = "Code block" }, {
            t({ "<pre class=code>" }), i(1),
            t({ "", "", "</pre>", "", "" }), i(0),
        }),

        s({ trig = "img", dscr = "Image" }, {
            t({ "<p>", "<%= post_img \"", }), i(1),
            t( "\", \"" ), i(2),
            t({ "\" %>", "", "<p>", "" }), i(0),
        }),

        s({ trig = "addr", dscr = "email link" }, {
            t("<a href=\"mailto:ams@toroid.org\">ams@toroid.org</a>"),
            t(""),
        }),

        s({ trig = "twittr", dscr = "Twitter link" }, {
            t("<a href=\"https://twitter.com/amenonsen\">@amenonsen</a>"),
            t(""),
        }),
    }
}
