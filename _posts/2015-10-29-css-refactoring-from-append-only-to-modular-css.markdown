---
layout: post
title: "CSS Refactoring: From append-only to modular CSS"
---

**Definition: Append-only CSS**: *CSS you are so afraid of changing that you exclusively append new rules to one never-ending file, leading inexorably to bewilderingly complex selectors with CSS specificity scores so high they'll break your calculator.* Sounds scary? Sounds familiar? Read on.

![Why CSS property !more-important DOESN'T EXIST](/images/css_refactor/more_important.jpg)

### Is refactoring CSS really worth the effort?

Oxbridge Notes started six years ago as a Rails 2.x application (now Rails 4.2) back when mobile internet access wasn't yet a thing and the only possible meaning of SASS was the first four letters of the word "SASSY". The website was initially developed on top of the [Spree](https://github.com/spree/spree) gem (a nice little e-commerce plugin in the Ruby world), inheriting all its superfluous (for our use-case) styles, leading to a **right mess of CSS**. And it certainly didn't help that the founder [learned to program](http://www.jackkinsella.ie/2011/12/05/janki-method.html) by building this site sometimes through trial but, in his words, "mostly through error".

As you might surmise by looking around, shiny and sleek design isn't exactly our top priority... we just deliver a typical buying experience minus the fireworks and fleeting web-design fashions. That said, even though beautiful design isn't important to us, **manageable CSS** certainly is.

### What exactly is the problem with one long CSS file?

When you have one big fugly append-only CSS file, it's darned difficult to find anything. You don’t know what style definitions you’ve already written without an exhaustive scan of the entire CSS file. Either you check — Every. Single. Time. — or you give up, get sloppy, and start appending. Having one big, non-modular, append-only file like we did leads to nasty **duplication** of existing CSS styles, making future changes even more difficult because you now need to change the CSS style definitions in two, three, or even ten different places. Such duplication also causes minor **inconsistencies** ("The 50 shades of grey" problem) as you pick similar-but-not-quite-the-same colours each time you have to style the border of a box or highlight text. Visual inconsistency is annoying for the user, making your layout look **unprofessional** and subconsciously eroding brand trust. It's also a waste of programmer resources, since you effectively reinvent the wheel every time you need a border-box or highlight effect. Compare this sorry situation to one of modular CSS where you separate out components like fonts, forms, colour shades, and widgets into separate, cleanly labelled files, enabling you to quickly find and re-use stock components cleanly stored away for future.


What's more, our previous disaster of a CSS file dramatically increased the **training time required** for any new programmer joining the team. This reduces profits, plain and simple.

And now the last and most embarrassing straw: **responsiveness**. Oxbridge Notes was created just before mobile internet got really big. The site wasn't designed to work on mobile devices. This damaged both pride and profit: pride when demonstrating a crappy mobile version of the website on an iPhone at a conference, and profit when mobile would-be-customers abandon before buying because the user experience was so slow and confusing.

Unfortunately, "going responsive" was simply not possible with the old CSS structure. We were tightly coupled with a pre-responsive grid system, and what's more, all of our layout related styles were scattered haphazardly throughout our one big fugly append-only file. Our professional opinion about going responsive with the old setup: "No way". That's why we decided to, in the words of Kent Beck, ["make the change easy, then make the easy change."](https://twitter.com/kentbeck/status/250733358307500032)

### Our core principles for sensible CSS

![CSS is awesome on a cup](/images/css_refactor/css_is_awesome.jpg)

Before embarking on our **refactoring journey**, we researched and devised some principles to keep in mind during the CSS rewrite and to serve as an internal CSS style guide/README for all our present and future programmers.

1. Write in **SASS**. You'd be insane to forego the advantages of variables, mixins, and so on.
2. Never use an HTML ID for styling; **always use classes**. HTML IDs, when used correctly, appear only once in the whole page, which is the complete opposite of re-usability — one of the most basic goods in sensible engineering. Moreover, it's really hard to override selectors containing IDs and often the only way to overpower one HTML ID is to create another ID, causing IDs to propagate in the codebase like the pests they are. Better to leave the HTML IDs for unchanging Javascript or integration test hooks.
3. Name your CSS classes by their **visual function** rather than by their application-specific function. For example, say `.highlight-box` instead of `.bundle-product-discount-box`. Coding in this way means that you can re-use your existing style-sheets when you role out side-businesses. For example, we started out selling law notes but recently moved into law tutors business. Our old CSS classes had names like `.download_document_box`, a class name that makes sense when talking about digital documents but would only confuse when applied to the new domain of private tutors. A better name that fits both existing services — and any future ones — would be `.pretty_callout_box`.
4. **Avoid naming CSS classes after specific grid information**. There was (and still is) a dreadful anti-pattern in CSS communities whereby designers and creators of CSS frameworks (cough Twitter Bootstrap) believe that `.span-2` or `.cols-8` are reasonable names for CSS classes. The point of CSS is to give you the possibility to modify your design without affecting the markup (much). Hardcoding grids sizes into the HTML thwarts this goal, so it is advised against in any project expected to last longer than a weekend. More on how we avoided grid classes later.
5. **Split your CSS across files**. Ideally you would split everything into "components"/"widgets" and then compose pages from these atoms of design. Realistically though, you'll notice that some of your website pages have idiosyncrasies (e.g. a special layout, or a weird photo gallery that appears in just one article). In these cases you might create a file related to that specific page, only refactoring into a full-blown widget when it becomes clear that the element will be re-used elsewhere. This is a tradeoff, one that is motivated by practical budgetary concerns.
6. **Minimise nesting.** Introduce new classes instead of nesting selectors. The fact that SASS removes the pain of repeating selectors when nesting doesn't mean that you have to nest five levels deep.
7. **Never over-qualify a selector** (e.g. don't use `ul.nav` where `.nav` could do the same job.) And don't specify HTML elements alongside the custom class name (e.g. `h2.highlight`). Instead just use the class name alone and drop the base selector (e.g. the previous example should be `.highlight`). Over-qualifying selectors doesn't add any value.
8. Create styles for HTML elements (e.g. `h1`) only when styling base components which should be consistent in the whole application. **Avoid broad selectors** like `header ul` because it's likely that you have to override them in some places anyway. As we keep saying, most of the time you want to use a specific, well-named class whenever you want a particular style.
9. Embrace the basics of **Block-Element-Modifier**. You can read about it for example [here](http://www.integralist.co.uk/posts/bem.html). We used it quite lightly, but still it helped us a lot in organizing CSS styles.

### Our workflow for refactoring CSS

What was our recipe for refactoring?

1. **Concatenate everything!** It may sound weird to dump every CSS rule to one file, but that's what we did. [Zen]Sometimes it's good to take a step back to go forward.[/Zen]. Contrary to our above claims of having one big fugly append-only CSS file, we in fact had two big fugly append-only CSS files - one inherited from Spree and one of our own styles. This division didn't have any semantics and was slightly less than useless. We began refactoring by merging these two files.
2. **Remove styles which are unused**. This is a mundane process, but necessary. There were parts of the Spree library logic which we removed, but the related CSS styles were still lurking around. Removing them involved simple grepping through the codebase to check for class names and IDs that appeared in the CSS files but which were no longer present in the views.
3. Pick one component (e.g. pagination styling, the global sidebar, the flash message boxes, or the header) and move all related styles into a **separate file**.
4. **Check every CSS property** inside this new component file. Some of the rules do nothing. Delete. Others override each other without a reason. Clean these offenders up. Others again are near-duplicates of one another. Merge.
5. Replace existing selectors (be they IDs or just badly named old classes) with classes named according to the conventions we mention above.
6. The styles which remain in the big fugly append-only file (now hopefully not-that-big!) are probably related to specific pages. **Create a new CSS file for each page with custom designs** and apply the same procedure as for cleaning up components.
7. Procure some tissues or toilet paper. Open up the production version of your website (with the old CSS) side-by-side with your CSS rewrite running locally. Now go through every screen in your application comparing the two and looking for inconsistencies or broken items. Weep. ( I warned you about needing those tissues). **Fix all the remaining visual glitches**.

### How did you replace the grid and go responsive?

![One does not simply go mobile](/images/css_refactor/one_does_not_simply.jpg)

Once we had clean, modular CSS we could start working on responsiveness. We were using Skeleton 1.x (inherited from Spree) as our **grid system** and decided that we needed a more modern, responsive-ready grid framework, but we didn't want to use a full-blown CSS framework (like Bootstrap). Bootstrap comes with default styles for all HTML elements but we already had them styled. We didn't want to inherit all that bloat and risk clashes.

That's why we decided to use [Neat](http://neat.bourbon.io) - a tiny **semantic** grid framework created by Thoughtbot. Why semantic? Because it doesn't force you to clutter the markup with classes required for layout. Instead, it relies on SASS mixins.

We were anxious about this migration... it seemed like the programming equivalent of pulling out blocks in an advanced game of Jenga. How difficult was it in the end? Not much at all! The changes were localized so that areas requiring attention were easy to find. The migration went faster than we anticipated.

Here's how we prepared mobile and tablet versions of our site:
1. We decided which parts of the website should be responsive and which ones need not be. Landing pages, pages in the checkout flow, and application forms for leads bought through expensive paid marketing were obvious candidates for careful responsive treatment, since all the above pages impacted revenue rather directly. Other features didn't make the cut: we didn't go responsive with rarely used pages, such as our author dashboard page displaying commissions an author previously earned. We also left untreated any pages we thought were unlikely to be used by mobile users - e.g. our internal administration page which is nearly always operated by our staff on laptops and also our authors' file upload pages (since both common sense and Google Analytics data indicate that authors wait until they are on a laptop before engaging in their long upload sessions of up to 100 documents).
2. On the individual pages we decided to treat, we played the role of an editor in deciding what parts of each page should appear or disappear in our mobile version where screen space is tighter. In our product listing pages, detailed product tables with five columns of data were reduced to the most basic two columns: the product name and its price. Our on-site search function - not yet robust or heavily used - was removed from the mobile version of the site to give extra prominence to our taxon-based browsing. This taxon-based browsing was perched in a left sidebar of our laptop website, but we banished it below the main content in our mobile version so as to provide space for the unique info of every page. Instead, we put a prominent mobile-only link in the header that jumps down to the taxon-based browsing, saving the customer what would otherwise amount to a ridiculous amount of scrolling.
3. We defined **breakpoints** - screen widths where the layout changes. We went with 600px for mobile and 1000px for tablet. Thanks to the Neat framework, it was super simple to write media queries targeting these specific breakpoints so we could have three columns on desktop, two columns on tablet and one column on mobile.
4. We checked every page using Chrome DevTools Device Mode. This is a nice tool which simulates how the application looks like on different devices. You can choose the screen size from the predefined list (iPhone 5, iPad, Samsung Galaxy S4 and so on) and the tool gives you a really quick feedback. From time to time we used real devices to catch any weird quirks not present on the simulator.

### Concluding results, in facts and figures

1. We started with 3348 lines of CSS and ended up with only 972, meaning we managed to delete more than 2/3 thanks to deleting unused selectors, merging similar styles, and employing CSS re-usability techniques like mixins, variables, and functions.
2. Cleaning up the CSS took **81 programmer-hours** and changing the grid system/preparing responsive version of the site took an additional **24 programmer-hours**.
3. **Business value?** Besides the advantages of programmer maintainability, a preliminary analysis of sales figures indicates a whopping 8% increase over our expectation pre-refactor. This increase is likely explained by customers having enhanced trust of the website thanks to its new, more consistent design, as well as mobile visitors experiencing a better, more usable website and thereby completing more orders.

Co-author: [Jack Kinsella](http://www.jackkinsella.ie)

