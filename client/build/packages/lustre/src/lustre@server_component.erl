-module(lustre@server_component).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/lustre/server_component.gleam").
-export([element/2, script/0, route/1, method/1, include/2, subject/1, pid/1, register_subject/1, deregister_subject/1, register_callback/1, deregister_callback/1, emit/2, select/1, runtime_message_decoder/0, client_message_to_json/1]).
-export_type([transport_method/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(
    " Server components are an advanced feature that allows you to run components\n"
    " or full Lustre applications on the server. Updates are broadcast to a small\n"
    " (10kb!) client runtime that patches the DOM and events are sent back to the\n"
    " server component in real-time.\n"
    "\n"
    " ```text\n"
    " -- SERVER -----------------------------------------------------------------\n"
    "\n"
    "                  Msg                            Element(Msg)\n"
    " +--------+        v        +----------------+        v        +------+\n"
    " |        | <-------------- |                | <-------------- |      |\n"
    " | update |                 | Lustre runtime |                 | view |\n"
    " |        | --------------> |                | --------------> |      |\n"
    " +--------+        ^        +----------------+        ^        +------+\n"
    "         #(model, Effect(msg))  |        ^          Model\n"
    "                                |        |\n"
    "                                |        |\n"
    "                    DOM patches |        | DOM events\n"
    "                                |        |\n"
    "                                v        |\n"
    "                        +-----------------------+\n"
    "                        |                       |\n"
    "                        | Your WebSocket server |\n"
    "                        |                       |\n"
    "                        +-----------------------+\n"
    "                                |        ^\n"
    "                                |        |\n"
    "                    DOM patches |        | DOM events\n"
    "                                |        |\n"
    "                                v        |\n"
    " -- BROWSER ----------------------------------------------------------------\n"
    "                                |        ^\n"
    "                                |        |\n"
    "                    DOM patches |        | DOM events\n"
    "                                |        |\n"
    "                                v        |\n"
    "                            +----------------+\n"
    "                            |                |\n"
    "                            | Client runtime |\n"
    "                            |                |\n"
    "                            +----------------+\n"
    " ```\n"
    "\n"
    " > **Note**: Lustre's server component runtime is separate from your application's\n"
    " > WebSocket server. You're free to bring your own stack, connect multiple\n"
    " > clients to the same Lustre instance, or keep the application alive even when\n"
    " > no clients are connected.\n"
    "\n"
    " Lustre server components run next to the rest of your backend code, your\n"
    " services, your database, etc. Real-time applications like chat services, games,\n"
    " or components that can benefit from direct access to your backend services\n"
    " like an admin dashboard or data table are excellent candidates for server\n"
    " components.\n"
    "\n"
    " ## Examples\n"
    "\n"
    " Server components are a new feature in Lustre and we're still working on the\n"
    " best ways to use them and show them off. Here are a few examples we've\n"
    " developed so far:\n"
    "\n"
    " - [Basic setup](https://github.com/lustre-labs/lustre/tree/main/examples/06-server-components/01-basic-setup)\n"
    "\n"
    " - [Custom attributes and events](https://github.com/lustre-labs/lustre/tree/main/examples/06-server-components/02-attributes-and-events)\n"
    "\n"
    " - [Decoding DOM events](https://github.com/lustre-labs/lustre/tree/main/examples/06-server-components/03-event-include)\n"
    "\n"
    " - [Connecting more than one client](https://github.com/lustre-labs/lustre/tree/main/examples/06-server-components/04-multiple-clients)\n"
    "\n"
    " - [Adding publish-subscribe](https://github.com/lustre-labs/lustre/tree/main/examples/06-server-components/05-publish-subscribe)\n"
    "\n"
    " ## Getting help\n"
    "\n"
    " If you're having trouble with Lustre or not sure what the right way to do\n"
    " something is, the best place to get help is the [Gleam Discord server](https://discord.gg/Fm8Pwmy).\n"
    " You could also open an issue on the [Lustre GitHub repository](https://github.com/lustre-labs/lustre/issues).\n"
    "\n"
).

-type transport_method() :: web_socket | server_sent_events | polling.

-file("src/lustre/server_component.gleam", 143).
?DOC(
    " Render the server component custom element. This element acts as the thin\n"
    " client runtime for a server component running remotely. There are a handful\n"
    " of attributes you should provide to configure the client runtime:\n"
    "\n"
    " - [`route`](#route) is the URL your server component should connect to. This\n"
    "   **must** be provided before the client runtime will do anything. The route\n"
    "   can be a relative URL, in which case it will be resolved against the current\n"
    "   page URL.\n"
    "\n"
    " - [`method`](#method) is the transport method the client runtime should use.\n"
    "   This defaults to `WebSocket` enabling duplex communication between the client\n"
    "   and server runtime. Other options include `ServerSentEvents` and `Polling`\n"
    "   which are unidirectional transports.\n"
    "\n"
    " > **Note**: the server component runtime bundle must be included and sent to\n"
    " > the client for this to work correctly. You can do this by including the\n"
    " > JavaScript bundle found in Lustre's `priv/static` directory or by inlining\n"
    " > the script source directly with the [`script`](#script) element below.\n"
).
-spec element(
    list(lustre@vdom@vattr:attribute(YRY)),
    list(lustre@vdom@vnode:element(YRY))
) -> lustre@vdom@vnode:element(YRY).
element(Attributes, Children) ->
    lustre@element:element(
        <<"lustre-server-component"/utf8>>,
        Attributes,
        Children
    ).

-file("src/lustre/server_component.gleam", 155).
?DOC(
    " Inline the server component client runtime as a `<script>` tag. Where possible\n"
    " you should prefer serving the pre-built client runtime from Lustre's `priv/static`\n"
    " directory, but this inline script can be useful for development or scenarios\n"
    " where you don't control the HTML document.\n"
).
-spec script() -> lustre@vdom@vnode:element(any()).
script() ->
    lustre@element@html:script(
        [lustre@attribute:type_(<<"module"/utf8>>)],
        <<"function ge(s){return s.replaceAll(/[><&\"']/g,e=>{switch(e){case\">\":return\"&gt;\";case\"<\":return\"&lt;\";case\"'\":return\"&#39;\";case\"&\":return\"&amp;\";case'\"':return\"&quot;\";default:return e}})}function be(s){return ge(s)}function q(s){return be(s)}var ee=s=>s.head,L=s=>s.tail;var zt=5,Xn=(1<<zt)-1,Yn=Symbol(),Zn=Symbol();var Be=[\" \",\"	\",`\\n`,\"\\v\",\"\\f\",\"\\r\",\"\\x85\",\"\\u2028\",\"\\u2029\"].join(\"\"),Qr=new RegExp(`^[${Be}]*`),Kr=new RegExp(`[${Be}]*$`);var Ve=0,Ge=1,We=2,Je=0;var ce=2;var J=0,Q=1,ue=2,Qe=3,I=4,Ke=5;var Xe=0,Ye=1,Ze=2,et=3,tt=4,nt=5,rt=6;var st=\"	\",ot=\"\\r\";var w=(s,e)=>{if(Array.isArray(s))for(let t=0;t<s.length;t++)e(s[t]);else if(s)for(s;L(s);s=L(s))e(ee(s))};var y=()=>globalThis?.document,ae=\"http://www.w3.org/1999/xhtml\";var ct=!!globalThis.HTMLElement?.prototype?.moveBefore;var $n=globalThis.setTimeout,fe=globalThis.clearTimeout,gn=(s,e)=>y().createElementNS(s,e),ut=s=>y().createTextNode(s),at=s=>y().createComment(s),bn=()=>y().createDocumentFragment(),v=(s,e,t)=>s.insertBefore(e,t),ft=ct?(s,e,t)=>s.moveBefore(e,t):v,pt=(s,e)=>s.removeChild(e),wn=(s,e)=>s.getAttribute(e),dt=(s,e,t)=>s.setAttribute(e,t),yn=(s,e)=>s.removeAttribute(e),kn=(s,e,t,r)=>s.addEventListener(e,t,r),ht=(s,e,t)=>s.removeEventListener(e,t),vn=(s,e)=>s.innerHTML=e,En=(s,e)=>s.data=e,m=Symbol(\"lustre\"),de=class{constructor(e,t,r,n){this.kind=e,this.key=n,this.parent=t,this.children=[],this.node=r,this.endNode=null,this.handlers=new Map,this.throttles=new Map,this.debouncers=new Map}get isVirtual(){return this.kind===J||this.kind===I}get parentNode(){return this.isVirtual?this.node.parentNode:this.node}};var U=(s,e,t,r,n)=>{let o=new de(s,e,t,n);return t[m]=o,e?.children.splice(r,0,o),o},jn=s=>{let e=\"\";for(let t=s[m];t.parent;t=t.parent){let r=t.parent&&t.parent.kind===I?ot:st;if(t.key)e=`${r}${t.key}${e}`;else{let n=t.parent.children.indexOf(t);e=`${r}${n}${e}`}}return e.slice(1)},D=class{#r=null;#e;#n;#t=!1;constructor(e,t,r,{debug:n=!1}={}){this.#r=e,this.#e=t,this.#n=r,this.#t=n}mount(e){U(Q,null,this.#r,0,null),this.#d(this.#r,null,this.#r[m],0,e)}push(e,t=null){this.#i=t,this.#s.push({node:this.#r[m],patch:e}),this.#o()}#i;#s=[];#o(){let e=this.#s;for(;e.length;){let{node:t,patch:r}=e.pop(),{children:n}=t,{changes:o,removed:i,children:l}=r;w(o,c=>this.#h(t,c)),i&&this.#p(t,n.length-i,i),w(l,c=>{let u=n[c.index|0];this.#s.push({node:u,patch:c})})}}#h(e,t){switch(t.kind){case Xe:this.#E(e,t);break;case Ye:this.#b(e,t);break;case Ze:this.#v(e,t);break;case et:this.#a(e,t);break;case tt:this.#x(e,t);break;case nt:this.#c(e,t);break;case rt:this.#u(e,t);break}}#u(e,{children:t,before:r}){let n=bn(),o=this.#l(e,r);this.#$(n,null,e,r|0,t),v(e.parentNode,n,o)}#c(e,{index:t,with:r}){this.#p(e,t|0,1);let n=this.#l(e,t);this.#d(e.parentNode,n,e,t|0,r)}#l(e,t){t=t|0;let{children:r}=e,n=r.length;if(t<n)return r[t].node;if(e.endNode)return e.endNode;if(!e.isVirtual||!n)return null;let o=r[n-1];for(;o.isVirtual&&o.children.length;){if(o.endNode)return o.endNode.nextSibling;o=o.children[o.children.length-1]}return o.node.nextSibling}#a(e,{key:t,before:r}){r=r|0;let{children:n,parentNode:o}=e,i=n[r].node,l=n[r];for(let c=r+1;c<n.length;++c){let u=n[c];if(n[c]=l,l=u,u.key===t){n[r]=u;break}}this.#f(o,l,i)}#m(e,t,r){for(let n=0;n<t.length;++n)this.#f(e,t[n],r)}#f(e,t,r){ft(e,t.node,r),t.isVirtual&&this.#m(e,t.children,r),t.endNode&&ft(e,t.endNode,r)}#x(e,{index:t}){this.#p(e,t,1)}#p(e,t,r){let{children:n,parentNode:o}=e,i=n.splice(t,r);for(let l=0;l<i.length;++l){let c=i[l],{node:u,endNode:$,isVirtual:E,children:p}=c;pt(o,u),$&&pt(o,$),this.#g(c),E&&i.push(...p)}}#g(e){let{debouncers:t,children:r}=e;for(let{timeout:n}of t.values())n&&fe(n);t.clear(),w(r,n=>this.#g(n))}#v({node:e,handlers:t,throttles:r,debouncers:n},{added:o,removed:i}){w(i,({name:l})=>{t.delete(l)?(ht(e,l,pe),this.#_(r,l,0),this.#_(n,l,0)):(yn(e,l),mt[l]?.removed?.(e,l))}),w(o,l=>this.#k(e,l))}#E({node:e},{content:t}){En(e,t??\"\")}#b({node:e},{inner_html:t}){vn(e,t??\"\")}#$(e,t,r,n,o){w(o,i=>this.#d(e,t,r,n++,i))}#d(e,t,r,n,o){switch(o.kind){case Q:{let i=this.#w(r,n,o);this.#$(i,null,i[m],0,o.children),v(e,i,t);break}case ue:{let i=this.#j(r,n,o);v(e,i,t);break}case J:{let i=\"lustre:fragment\",l=this.#y(i,r,n,o);v(e,l,t),this.#$(e,t,l[m],0,o.children),this.#t&&(l[m].endNode=at(` /${i} `),v(e,l[m].endNode,t));break}case Qe:{let i=this.#w(r,n,o);this.#b({node:i},o),v(e,i,t);break}case I:{let i=this.#y(\"lustre:map\",r,n,o);v(e,i,t),this.#d(e,t,i[m],0,o.child);break}case Ke:{let i=this.#i?.get(o.view)??o.view();this.#d(e,t,r,n,i);break}}}#w(e,t,{kind:r,key:n,tag:o,namespace:i,attributes:l}){let c=gn(i||ae,o);return U(r,e,c,t,n),this.#t&&n&&dt(c,\"data-lustre-key\",n),w(l,u=>this.#k(c,u)),c}#j(e,t,{kind:r,key:n,content:o}){let i=ut(o??\"\");return U(r,e,i,t,n),i}#y(e,t,r,{kind:n,key:o}){let i=this.#t?at(Cn(e,o)):ut(\"\");return U(n,t,i,r,o),i}#k(e,t){let{debouncers:r,handlers:n,throttles:o}=e[m],{kind:i,name:l,value:c,prevent_default:u,debounce:$,throttle:E}=t;switch(i){case Ve:{let p=c??\"\";if(l===\"virtual:defaultValue\"){e.defaultValue=p;return}else if(l===\"virtual:defaultChecked\"){e.defaultChecked=!0;return}else if(l===\"virtual:defaultSelected\"){e.defaultSelected=!0;return}p!==wn(e,l)&&dt(e,l,p),mt[l]?.added?.(e,p);break}case Ge:e[l]=c;break;case We:{n.has(l)&&ht(e,l,pe);let p=u.kind===Je;kn(e,l,pe,{passive:p}),this.#_(o,l,E),this.#_(r,l,$),n.set(l,j=>this.#C(t,j));break}}}#_(e,t,r){let n=e.get(t);if(r>0)n?n.delay=r:e.set(t,{delay:r});else if(n){let{timeout:o}=n;o&&fe(o),e.delete(t)}}#C(e,t){let{currentTarget:r,type:n}=t,{debouncers:o,throttles:i}=r[m],l=jn(r),{prevent_default:c,stop_propagation:u,include:$}=e;c.kind===ce&&t.preventDefault(),u.kind===ce&&t.stopPropagation(),n===\"submit\"&&(t.detail??={},t.detail.formData=[...new FormData(t.target,t.submitter).entries()]);let E=this.#e(t,l,n,$),p=i.get(n);if(p){let $e=Date.now(),St=p.last||0;$e>St+p.delay&&(p.last=$e,p.lastEvent=t,this.#n(t,E))}let j=o.get(n);j&&(fe(j.timeout),j.timeout=$n(()=>{t!==i.get(n)?.lastEvent&&this.#n(t,E)},j.delay)),!p&&!j&&this.#n(t,E)}},Cn=(s,e)=>e?` ${s} key=\"${q(e)}\" `:` ${s} `,pe=s=>{let{currentTarget:e,type:t}=s;e[m].handlers.get(t)(s)},_t=s=>({added(e){e[s]=!0},removed(e){e[s]=!1}}),Sn=s=>({added(e,t){e[s]=t}}),mt={checked:_t(\"checked\"),selected:_t(\"selected\"),value:Sn(\"value\"),autofocus:{added(s){queueMicrotask(()=>{s.focus?.()})}},autoplay:{added(s){try{s.play?.()}catch(e){console.error(e)}}}};var gt=new WeakMap;async function bt(s){let e=[];for(let r of y().querySelectorAll(\"link[rel=stylesheet], style\"))r.sheet||e.push(new Promise((n,o)=>{r.addEventListener(\"load\",n),r.addEventListener(\"error\",o)}));if(await Promise.allSettled(e),!s.host.isConnected)return[];s.adoptedStyleSheets=s.host.getRootNode().adoptedStyleSheets;let t=[];for(let r of y().styleSheets)try{s.adoptedStyleSheets.push(r)}catch{try{let n=gt.get(r);if(!n){n=new CSSStyleSheet;for(let o of r.cssRules)n.insertRule(o.cssText,n.cssRules.length);gt.set(r,n)}s.adoptedStyleSheets.push(n)}catch{let n=r.ownerNode.cloneNode();s.prepend(n),t.push(n)}}return t}var X=class extends Event{constructor(e,t,r){super(\"context-request\",{bubbles:!0,composed:!0}),this.context=e,this.callback=t,this.subscribe=r}};var wt=0,yt=1,kt=2,vt=3,Y=0,Et=1,jt=2,Z=3,Ct=4;var he=class extends HTMLElement{static get observedAttributes(){return[\"route\",\"method\"]}#r;#e=\"ws\";#n=null;#t=null;#i=[];#s;#o=new Set;#h=new Set;#u=!1;#c=[];#l=new Map;#a=new Set;#m=new MutationObserver(e=>{let t=[];for(let r of e){if(r.type!==\"attributes\")continue;let n=r.attributeName;(!this.#u||this.#o.has(n))&&t.push([n,this.getAttribute(n)])}if(t.length===1){let[r,n]=t[0];this.#t?.send({kind:Y,name:r,value:n})}else t.length?this.#t?.send({kind:Z,messages:t.map(([r,n])=>({kind:Y,name:r,value:n}))}):this.#c.push(...t)});constructor(){super(),this.internals=this.attachInternals(),this.#m.observe(this,{attributes:!0})}connectedCallback(){for(let e of this.attributes)this.#c.push([e.name,e.value])}attributeChangedCallback(e,t,r){switch(e){case(t!==r&&\"route\"):{this.#n=new URL(r,location.href),this.#f();return}case\"method\":{let n=r.toLowerCase();if(n==this.#e)return;[\"ws\",\"sse\",\"polling\"].includes(n)&&(this.#e=n,this.#e==\"ws\"&&(this.#n.protocol==\"https:\"&&(this.#n.protocol=\"wss:\"),this.#n.protocol==\"http:\"&&(this.#n.protocol=\"ws:\")),this.#f());return}}}async messageReceivedCallback(e){switch(e.kind){case wt:{for(this.#r??=this.attachShadow({mode:e.open_shadow_root?\"open\":\"closed\"});this.#r.firstChild;)this.#r.firstChild.remove();let t=(i,l,c,u)=>{let $=this.#p(i,u??[]);return{kind:Et,path:l,name:c,event:$}},r=(i,l)=>{this.#t?.send(l)};this.#s=new D(this.#r,t,r),this.#o=new Set(e.observed_attributes);let o=this.#c.filter(([i])=>this.#o.has(i)).map(([i,l])=>({kind:Y,name:i,value:l}));this.#c=[],this.#h=new Set(e.observed_properties);for(let i of this.#h)Object.defineProperty(this,i,{get(){return this[`_${i}`]},set(l){this[`_${i}`]=l,this.#t?.send({kind:jt,name:i,value:l})}});for(let[i,l]of Object.entries(e.provided_contexts))this.provide(i,l);for(let i of[...new Set(e.requested_contexts)])this.dispatchEvent(new X(i,(l,c)=>{this.#t?.send({kind:Ct,key:i,value:l}),this.#a.add(c)}));o.length&&this.#t.send({kind:Z,messages:o}),e.will_adopt_styles&&await this.#x(),this.#r.addEventListener(\"context-request\",i=>{if(!i.context||!i.callback||!this.#l.has(i.context))return;i.stopImmediatePropagation();let l=this.#l.get(i.context);if(i.subscribe){let c=new WeakRef(i.callback),u=()=>{l.subscribers=l.subscribers.filter($=>$!==c)};l.subscribers.push([c,u]),i.callback(l.value,u)}else i.callback(l.value)}),this.#s.mount(e.vdom),this.dispatchEvent(new CustomEvent(\"lustre:mount\"));break}case yt:{this.#s.push(e.patch);break}case kt:{this.dispatchEvent(new CustomEvent(e.name,{detail:e.data}));break}case vt:{this.provide(e.key,e.value);break}}}disconnectedCallback(){for(let e of this.#a)e();this.#a.clear()}provide(e,t){if(!this.#l.has(e))this.#l.set(e,{value:t,subscribers:[]});else{let r=this.#l.get(e);r.value=t;for(let n=r.subscribers.length-1;n>=0;n--){let[o,i]=r.subscribers[n],l=o.deref();if(!l){r.subscribers.splice(n,1);continue}l(t,i)}}}#f(){if(!this.#n||!this.#e)return;this.#t&&this.#t.close();let n={onConnect:()=>{this.#u=!0,this.dispatchEvent(new CustomEvent(\"lustre:connect\"),{detail:{route:this.#n,method:this.#e}})},onMessage:o=>{this.messageReceivedCallback(o)},onClose:()=>{this.#u=!1,this.dispatchEvent(new CustomEvent(\"lustre:close\",{detail:{route:this.#n,method:this.#e}}))}};switch(this.#e){case\"ws\":this.#t=new _e(this.#n,n);break;case\"sse\":this.#t=new me(this.#n,n);break;case\"polling\":this.#t=new xe(this.#n,n);break}}async#x(){for(;this.#i.length;)this.#i.pop().remove(),this.#r.firstChild.remove();this.#i=await bt(this.#r)}#p(e,t=[]){let r={};(e.type===\"input\"||e.type===\"change\")&&t.push(\"target.value\"),e.type===\"submit\"&&t.push(\"detail.formData\");for(let n of t){let o=n.split(\".\");for(let i=0,l=e,c=r;i<o.length;i++){if(i===o.length-1){c[o[i]]=l[o[i]];break}c=c[o[i]]??={},l=l[o[i]]}}return r}},_e=class{#r;#e;#n=!1;#t=[];#i;#s;#o;constructor(e,{onConnect:t,onMessage:r,onClose:n}){this.#r=e,this.#e=new WebSocket(this.#r),this.#i=t,this.#s=r,this.#o=n,this.#e.onopen=()=>{this.#i()},this.#e.onmessage=({data:o})=>{try{this.#s(JSON.parse(o))}finally{this.#t.length?this.#e.send(JSON.stringify({kind:Z,messages:this.#t})):this.#n=!1,this.#t=[]}},this.#e.onclose=()=>{this.#o()}}send(e){if(this.#n||this.#e.readyState!==WebSocket.OPEN){this.#t.push(e);return}else this.#e.send(JSON.stringify(e)),this.#n=!0}close(){this.#e.close()}},me=class{#r;#e;#n;#t;#i;constructor(e,{onConnect:t,onMessage:r,onClose:n}){this.#r=e,this.#e=new EventSource(this.#r),this.#n=t,this.#t=r,this.#i=n,this.#e.onopen=()=>{this.#n()},this.#e.onmessage=({data:o})=>{try{this.#t(JSON.parse(o))}catch{}}}send(e){}close(){this.#e.close(),this.#i()}},xe=class{#r;#e;#n;#t;#i;#s;constructor(e,{onConnect:t,onMessage:r,onClose:n,...o}){this.#r=e,this.#t=t,this.#i=r,this.#s=n,this.#e=o.interval??5e3,this.#o().finally(()=>{this.#t(),this.#n=setInterval(()=>this.#o(),this.#e)})}async send(e){}close(){clearInterval(this.#n),this.#s()}#o(){return fetch(this.#r).then(e=>e.json()).then(this.#i).catch(console.error)}};customElements.define(\"lustre-server-component\",he);export{he as ServerComponent};"/utf8>>
    ).

-file("src/lustre/server_component.gleam", 170).
?DOC(
    " The `route` attribute tells the client runtime what route it should use to\n"
    " set up the WebSocket connection to the server. Whenever this attribute is\n"
    " changed (by a clientside Lustre app, for example), the client runtime will\n"
    " destroy the current connection and set up a new one.\n"
).
-spec route(binary()) -> lustre@vdom@vattr:attribute(any()).
route(Path) ->
    lustre@attribute:attribute(<<"route"/utf8>>, Path).

-file("src/lustre/server_component.gleam", 176).
?DOC("\n").
-spec method(transport_method()) -> lustre@vdom@vattr:attribute(any()).
method(Value) ->
    lustre@attribute:attribute(<<"method"/utf8>>, case Value of
            web_socket ->
                <<"ws"/utf8>>;

            server_sent_events ->
                <<"sse"/utf8>>;

            polling ->
                <<"polling"/utf8>>
        end).

-file("src/lustre/server_component.gleam", 213).
?DOC(
    " Properties of a JavaScript event object are typically not serialisable. This\n"
    " means if we want to send them to the server we need to make a copy of any\n"
    " fields we want to decode first.\n"
    "\n"
    " This attribute tells Lustre what properties to include from an event. Properties\n"
    " can come from nested fields by using dot notation. For example, you could include\n"
    " the\n"
    " `id` of the target `element` by passing `[\"target.id\"]`.\n"
    "\n"
    " ```gleam\n"
    " import gleam/dynamic/decode\n"
    " import lustre/element.{type Element}\n"
    " import lustre/element/html\n"
    " import lustre/event\n"
    " import lustre/server_component\n"
    "\n"
    " pub fn custom_button(on_click: fn(String) -> msg) -> Element(msg) {\n"
    "   let handler = fn(event) {\n"
    "     use id <- decode.at([\"target\", \"id\"], decode.string)\n"
    "     decode.success(on_click(id))\n"
    "   }\n"
    "\n"
    "   html.button(\n"
    "     [server_component.include([\"target.id\"]), event.on(\"click\", handler)],\n"
    "     [html.text(\"Click me!\")],\n"
    "   )\n"
    " }\n"
    " ```\n"
).
-spec include(lustre@vdom@vattr:attribute(YSK), list(binary())) -> lustre@vdom@vattr:attribute(YSK).
include(Event, Properties) ->
    case Event of
        {event, _, _, _, _, _, _, _, _} ->
            {event,
                erlang:element(2, Event),
                erlang:element(3, Event),
                erlang:element(4, Event),
                Properties,
                erlang:element(6, Event),
                erlang:element(7, Event),
                erlang:element(8, Event),
                erlang:element(9, Event)};

        _ ->
            Event
    end.

-file("src/lustre/server_component.gleam", 233).
?DOC(
    " Recover the `Subject` of the server component runtime so that it can be used\n"
    " in supervision trees or passed to other processes. If you want to hand out\n"
    " different `Subject`s to send messages to your application, take a look at the\n"
    " [`select`](#select) effect.\n"
    "\n"
    " > **Note**: this function is not available on the JavaScript target.\n"
).
-spec subject(lustre:runtime(YSO)) -> gleam@erlang@process:subject(lustre@runtime@server@runtime:message(YSO)).
subject(Runtime) ->
    gleam@function:identity(Runtime).

-file("src/lustre/server_component.gleam", 245).
?DOC(
    " Recover the `Pid` of the server component runtime so that it can be used in\n"
    " supervision trees or passed to other processes. If you want to hand out\n"
    " different `Subject`s to send messages to your application, take a look at the\n"
    " [`select`](#select) effect.\n"
    "\n"
    " > **Note**: this function is not available on the JavaScript target.\n"
).
-spec pid(lustre:runtime(any())) -> gleam@erlang@process:pid_().
pid(Runtime) ->
    Pid@1 = case gleam@erlang@process:subject_owner(subject(Runtime)) of
        {ok, Pid} -> Pid;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"lustre/server_component"/utf8>>,
                        function => <<"pid"/utf8>>,
                        line => 246,
                        value => _assert_fail,
                        start => 22574,
                        'end' => 22634,
                        pattern_start => 22585,
                        pattern_end => 22592})
    end,
    Pid@1.

-file("src/lustre/server_component.gleam", 262).
?DOC(
    " Register a `Subject` to receive messages and updates from Lustre's server\n"
    " component runtime. The process that owns this will be monitored and the\n"
    " subject will be gracefully removed if the process dies.\n"
    "\n"
    " > **Note**: if you are developing a server component for the JavaScript runtime,\n"
    " > you should use [`register_callback`](#register_callback) instead.\n"
).
-spec register_subject(
    gleam@erlang@process:subject(lustre@runtime@transport:client_message(YSW))
) -> lustre@runtime@server@runtime:message(YSW).
register_subject(Client) ->
    {client_registered_subject, Client}.

-file("src/lustre/server_component.gleam", 272).
?DOC(
    " Deregister a `Subject` to stop receiving messages and updates from Lustre's\n"
    " server component runtime. The subject should first have been registered with\n"
    " [`register_subject`](#register_subject) otherwise this will do nothing.\n"
).
-spec deregister_subject(
    gleam@erlang@process:subject(lustre@runtime@transport:client_message(YTA))
) -> lustre@runtime@server@runtime:message(YTA).
deregister_subject(Client) ->
    {client_deregistered_subject, Client}.

-file("src/lustre/server_component.gleam", 286).
?DOC(
    " Register a callback to be called whenever the server component runtime\n"
    " produces a message. Avoid using anonymous functions with this function, as\n"
    " they cannot later be removed using [`deregister_callback`](#deregister_callback).\n"
    "\n"
    " > **Note**: server components running on the Erlang target are **strongly**\n"
    " > encouraged to use [`register_subject`](#register_subject) instead of this\n"
    " > function.\n"
).
-spec register_callback(
    fun((lustre@runtime@transport:client_message(YTE)) -> nil)
) -> lustre@runtime@server@runtime:message(YTE).
register_callback(Callback) ->
    {client_registered_callback, Callback}.

-file("src/lustre/server_component.gleam", 300).
?DOC(
    " Deregister a callback to be called whenever the server component runtime\n"
    " produces a message. The callback to remove is determined by function equality\n"
    " and must be the same function that was passed to [`register_callback`](#register_callback).\n"
    "\n"
    " > **Note**: server components running on the Erlang target are **strongly**\n"
    " > encouraged to use [`register_subject`](#register_subject) instead of this\n"
    " > function.\n"
).
-spec deregister_callback(
    fun((lustre@runtime@transport:client_message(YTH)) -> nil)
) -> lustre@runtime@server@runtime:message(YTH).
deregister_callback(Callback) ->
    {client_deregistered_callback, Callback}.

-file("src/lustre/server_component.gleam", 316).
?DOC(
    " Instruct any connected clients to emit a DOM event with the given name and\n"
    " data. This lets your server component communicate to the frontend the same way\n"
    " any other HTML elements do: you might emit a `\"change\"` event when some part\n"
    " of the server component's state changes, for example.\n"
    "\n"
    " This is a real DOM event and any JavaScript on the page can attach an event\n"
    " listener to the server component element and listen for these events.\n"
).
-spec emit(binary(), gleam@json:json()) -> lustre@effect:effect(any()).
emit(Event, Data) ->
    lustre@effect:event(Event, Data).

-file("src/lustre/server_component.gleam", 339).
?DOC(
    " On the Erlang target, Lustre's server component runtime is an OTP\n"
    " [actor](https://hexdocs.pm/gleam_otp/gleam/otp/actor.html) that can be\n"
    " communicated with using the standard process API and the `Subject` returned\n"
    " when starting the server component.\n"
    "\n"
    " Sometimes, you might want to hand a different `Subject` to a process to restrict\n"
    " the type of messages it can send or to distinguish messages from different\n"
    " sources from one another. The `select` effect creates a fresh `Subject` each\n"
    " time it is run. By returning a `Selector` you can teach the Lustre server\n"
    " component runtime how to listen to messages from this `Subject`.\n"
    "\n"
    " The `select` effect also gives you the dispatch function passed to `effect.from`.\n"
    " This is useful in case you want to store the provided `Subject` in your model\n"
    " for later use. For example you may subscribe to a pubsub service and later use\n"
    " that same `Subject` to unsubscribe.\n"
    "\n"
    " > **Note**: This effect does nothing on the JavaScript runtime, where `Subject`s\n"
    " > and `Selector`s don't exist, and is the equivalent of returning `effect.none()`.\n"
).
-spec select(
    fun((fun((YTM) -> nil), gleam@erlang@process:subject(any())) -> gleam@erlang@process:selector(YTM))
) -> lustre@effect:effect(YTM).
select(Sel) ->
    lustre@effect:select(Sel).

-file("src/lustre/server_component.gleam", 352).
?DOC(
    " The server component client runtime sends JSON-encoded messages for the server\n"
    " runtime to execute. Because your own WebSocket server sits between the two\n"
    " parts of the runtime, you need to decode these actions and pass them to the\n"
    " server runtime yourself.\n"
).
-spec runtime_message_decoder() -> gleam@dynamic@decode:decoder(lustre@runtime@server@runtime:message(any())).
runtime_message_decoder() ->
    gleam@dynamic@decode:map(
        lustre@runtime@transport:server_message_decoder(),
        fun(Field@0) -> {client_dispatched_message, Field@0} end
    ).

-file("src/lustre/server_component.gleam", 368).
?DOC(
    " Encode a message you can send to the client runtime to respond to. The server\n"
    " component runtime will send messages to any registered clients to instruct\n"
    " them to update their DOM or emit events, for example.\n"
    "\n"
    " Because your WebSocket server sits between the two parts of the runtime, you\n"
    " need to encode these actions and send them to the client runtime yourself.\n"
).
-spec client_message_to_json(lustre@runtime@transport:client_message(any())) -> gleam@json:json().
client_message_to_json(Message) ->
    lustre@runtime@transport:client_message_to_json(Message).
