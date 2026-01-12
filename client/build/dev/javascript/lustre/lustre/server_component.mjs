import * as $process from "../../gleam_erlang/gleam/erlang/process.mjs";
import * as $json from "../../gleam_json/gleam/json.mjs";
import * as $decode from "../../gleam_stdlib/gleam/dynamic/decode.mjs";
import { toList, CustomType as $CustomType } from "../gleam.mjs";
import * as $lustre from "../lustre.mjs";
import * as $attribute from "../lustre/attribute.mjs";
import { attribute } from "../lustre/attribute.mjs";
import * as $effect from "../lustre/effect.mjs";
import * as $element from "../lustre/element.mjs";
import * as $html from "../lustre/element/html.mjs";
import * as $runtime from "../lustre/runtime/server/runtime.mjs";
import * as $transport from "../lustre/runtime/transport.mjs";
import * as $vattr from "../lustre/vdom/vattr.mjs";
import { Event } from "../lustre/vdom/vattr.mjs";

export class WebSocket extends $CustomType {}
export const TransportMethod$WebSocket = () => new WebSocket();
export const TransportMethod$isWebSocket = (value) =>
  value instanceof WebSocket;

export class ServerSentEvents extends $CustomType {}
export const TransportMethod$ServerSentEvents = () => new ServerSentEvents();
export const TransportMethod$isServerSentEvents = (value) =>
  value instanceof ServerSentEvents;

export class Polling extends $CustomType {}
export const TransportMethod$Polling = () => new Polling();
export const TransportMethod$isPolling = (value) => value instanceof Polling;

/**
 * Render the server component custom element. This element acts as the thin
 * client runtime for a server component running remotely. There are a handful
 * of attributes you should provide to configure the client runtime:
 *
 * - [`route`](#route) is the URL your server component should connect to. This
 *   **must** be provided before the client runtime will do anything. The route
 *   can be a relative URL, in which case it will be resolved against the current
 *   page URL.
 *
 * - [`method`](#method) is the transport method the client runtime should use.
 *   This defaults to `WebSocket` enabling duplex communication between the client
 *   and server runtime. Other options include `ServerSentEvents` and `Polling`
 *   which are unidirectional transports.
 *
 * > **Note**: the server component runtime bundle must be included and sent to
 * > the client for this to work correctly. You can do this by including the
 * > JavaScript bundle found in Lustre's `priv/static` directory or by inlining
 * > the script source directly with the [`script`](#script) element below.
 */
export function element(attributes, children) {
  return $element.element("lustre-server-component", attributes, children);
}

/**
 * Inline the server component client runtime as a `<script>` tag. Where possible
 * you should prefer serving the pre-built client runtime from Lustre's `priv/static`
 * directory, but this inline script can be useful for development or scenarios
 * where you don't control the HTML document.
 */
export function script() {
  return $html.script(
    toList([$attribute.type_("module")]),
    "function ge(s){return s.replaceAll(/[><&\"']/g,e=>{switch(e){case\">\":return\"&gt;\";case\"<\":return\"&lt;\";case\"'\":return\"&#39;\";case\"&\":return\"&amp;\";case'\"':return\"&quot;\";default:return e}})}function be(s){return ge(s)}function q(s){return be(s)}var ee=s=>s.head,L=s=>s.tail;var zt=5,Xn=(1<<zt)-1,Yn=Symbol(),Zn=Symbol();var Be=[\" \",\"	\",`\\n`,\"\\v\",\"\\f\",\"\\r\",\"\\x85\",\"\\u2028\",\"\\u2029\"].join(\"\"),Qr=new RegExp(`^[${Be}]*`),Kr=new RegExp(`[${Be}]*$`);var Ve=0,Ge=1,We=2,Je=0;var ce=2;var J=0,Q=1,ue=2,Qe=3,I=4,Ke=5;var Xe=0,Ye=1,Ze=2,et=3,tt=4,nt=5,rt=6;var st=\"	\",ot=\"\\r\";var w=(s,e)=>{if(Array.isArray(s))for(let t=0;t<s.length;t++)e(s[t]);else if(s)for(s;L(s);s=L(s))e(ee(s))};var y=()=>globalThis?.document,ae=\"http://www.w3.org/1999/xhtml\";var ct=!!globalThis.HTMLElement?.prototype?.moveBefore;var $n=globalThis.setTimeout,fe=globalThis.clearTimeout,gn=(s,e)=>y().createElementNS(s,e),ut=s=>y().createTextNode(s),at=s=>y().createComment(s),bn=()=>y().createDocumentFragment(),v=(s,e,t)=>s.insertBefore(e,t),ft=ct?(s,e,t)=>s.moveBefore(e,t):v,pt=(s,e)=>s.removeChild(e),wn=(s,e)=>s.getAttribute(e),dt=(s,e,t)=>s.setAttribute(e,t),yn=(s,e)=>s.removeAttribute(e),kn=(s,e,t,r)=>s.addEventListener(e,t,r),ht=(s,e,t)=>s.removeEventListener(e,t),vn=(s,e)=>s.innerHTML=e,En=(s,e)=>s.data=e,m=Symbol(\"lustre\"),de=class{constructor(e,t,r,n){this.kind=e,this.key=n,this.parent=t,this.children=[],this.node=r,this.endNode=null,this.handlers=new Map,this.throttles=new Map,this.debouncers=new Map}get isVirtual(){return this.kind===J||this.kind===I}get parentNode(){return this.isVirtual?this.node.parentNode:this.node}};var U=(s,e,t,r,n)=>{let o=new de(s,e,t,n);return t[m]=o,e?.children.splice(r,0,o),o},jn=s=>{let e=\"\";for(let t=s[m];t.parent;t=t.parent){let r=t.parent&&t.parent.kind===I?ot:st;if(t.key)e=`${r}${t.key}${e}`;else{let n=t.parent.children.indexOf(t);e=`${r}${n}${e}`}}return e.slice(1)},D=class{#r=null;#e;#n;#t=!1;constructor(e,t,r,{debug:n=!1}={}){this.#r=e,this.#e=t,this.#n=r,this.#t=n}mount(e){U(Q,null,this.#r,0,null),this.#d(this.#r,null,this.#r[m],0,e)}push(e,t=null){this.#i=t,this.#s.push({node:this.#r[m],patch:e}),this.#o()}#i;#s=[];#o(){let e=this.#s;for(;e.length;){let{node:t,patch:r}=e.pop(),{children:n}=t,{changes:o,removed:i,children:l}=r;w(o,c=>this.#h(t,c)),i&&this.#p(t,n.length-i,i),w(l,c=>{let u=n[c.index|0];this.#s.push({node:u,patch:c})})}}#h(e,t){switch(t.kind){case Xe:this.#E(e,t);break;case Ye:this.#b(e,t);break;case Ze:this.#v(e,t);break;case et:this.#a(e,t);break;case tt:this.#x(e,t);break;case nt:this.#c(e,t);break;case rt:this.#u(e,t);break}}#u(e,{children:t,before:r}){let n=bn(),o=this.#l(e,r);this.#$(n,null,e,r|0,t),v(e.parentNode,n,o)}#c(e,{index:t,with:r}){this.#p(e,t|0,1);let n=this.#l(e,t);this.#d(e.parentNode,n,e,t|0,r)}#l(e,t){t=t|0;let{children:r}=e,n=r.length;if(t<n)return r[t].node;if(e.endNode)return e.endNode;if(!e.isVirtual||!n)return null;let o=r[n-1];for(;o.isVirtual&&o.children.length;){if(o.endNode)return o.endNode.nextSibling;o=o.children[o.children.length-1]}return o.node.nextSibling}#a(e,{key:t,before:r}){r=r|0;let{children:n,parentNode:o}=e,i=n[r].node,l=n[r];for(let c=r+1;c<n.length;++c){let u=n[c];if(n[c]=l,l=u,u.key===t){n[r]=u;break}}this.#f(o,l,i)}#m(e,t,r){for(let n=0;n<t.length;++n)this.#f(e,t[n],r)}#f(e,t,r){ft(e,t.node,r),t.isVirtual&&this.#m(e,t.children,r),t.endNode&&ft(e,t.endNode,r)}#x(e,{index:t}){this.#p(e,t,1)}#p(e,t,r){let{children:n,parentNode:o}=e,i=n.splice(t,r);for(let l=0;l<i.length;++l){let c=i[l],{node:u,endNode:$,isVirtual:E,children:p}=c;pt(o,u),$&&pt(o,$),this.#g(c),E&&i.push(...p)}}#g(e){let{debouncers:t,children:r}=e;for(let{timeout:n}of t.values())n&&fe(n);t.clear(),w(r,n=>this.#g(n))}#v({node:e,handlers:t,throttles:r,debouncers:n},{added:o,removed:i}){w(i,({name:l})=>{t.delete(l)?(ht(e,l,pe),this.#_(r,l,0),this.#_(n,l,0)):(yn(e,l),mt[l]?.removed?.(e,l))}),w(o,l=>this.#k(e,l))}#E({node:e},{content:t}){En(e,t??\"\")}#b({node:e},{inner_html:t}){vn(e,t??\"\")}#$(e,t,r,n,o){w(o,i=>this.#d(e,t,r,n++,i))}#d(e,t,r,n,o){switch(o.kind){case Q:{let i=this.#w(r,n,o);this.#$(i,null,i[m],0,o.children),v(e,i,t);break}case ue:{let i=this.#j(r,n,o);v(e,i,t);break}case J:{let i=\"lustre:fragment\",l=this.#y(i,r,n,o);v(e,l,t),this.#$(e,t,l[m],0,o.children),this.#t&&(l[m].endNode=at(` /${i} `),v(e,l[m].endNode,t));break}case Qe:{let i=this.#w(r,n,o);this.#b({node:i},o),v(e,i,t);break}case I:{let i=this.#y(\"lustre:map\",r,n,o);v(e,i,t),this.#d(e,t,i[m],0,o.child);break}case Ke:{let i=this.#i?.get(o.view)??o.view();this.#d(e,t,r,n,i);break}}}#w(e,t,{kind:r,key:n,tag:o,namespace:i,attributes:l}){let c=gn(i||ae,o);return U(r,e,c,t,n),this.#t&&n&&dt(c,\"data-lustre-key\",n),w(l,u=>this.#k(c,u)),c}#j(e,t,{kind:r,key:n,content:o}){let i=ut(o??\"\");return U(r,e,i,t,n),i}#y(e,t,r,{kind:n,key:o}){let i=this.#t?at(Cn(e,o)):ut(\"\");return U(n,t,i,r,o),i}#k(e,t){let{debouncers:r,handlers:n,throttles:o}=e[m],{kind:i,name:l,value:c,prevent_default:u,debounce:$,throttle:E}=t;switch(i){case Ve:{let p=c??\"\";if(l===\"virtual:defaultValue\"){e.defaultValue=p;return}else if(l===\"virtual:defaultChecked\"){e.defaultChecked=!0;return}else if(l===\"virtual:defaultSelected\"){e.defaultSelected=!0;return}p!==wn(e,l)&&dt(e,l,p),mt[l]?.added?.(e,p);break}case Ge:e[l]=c;break;case We:{n.has(l)&&ht(e,l,pe);let p=u.kind===Je;kn(e,l,pe,{passive:p}),this.#_(o,l,E),this.#_(r,l,$),n.set(l,j=>this.#C(t,j));break}}}#_(e,t,r){let n=e.get(t);if(r>0)n?n.delay=r:e.set(t,{delay:r});else if(n){let{timeout:o}=n;o&&fe(o),e.delete(t)}}#C(e,t){let{currentTarget:r,type:n}=t,{debouncers:o,throttles:i}=r[m],l=jn(r),{prevent_default:c,stop_propagation:u,include:$}=e;c.kind===ce&&t.preventDefault(),u.kind===ce&&t.stopPropagation(),n===\"submit\"&&(t.detail??={},t.detail.formData=[...new FormData(t.target,t.submitter).entries()]);let E=this.#e(t,l,n,$),p=i.get(n);if(p){let $e=Date.now(),St=p.last||0;$e>St+p.delay&&(p.last=$e,p.lastEvent=t,this.#n(t,E))}let j=o.get(n);j&&(fe(j.timeout),j.timeout=$n(()=>{t!==i.get(n)?.lastEvent&&this.#n(t,E)},j.delay)),!p&&!j&&this.#n(t,E)}},Cn=(s,e)=>e?` ${s} key=\"${q(e)}\" `:` ${s} `,pe=s=>{let{currentTarget:e,type:t}=s;e[m].handlers.get(t)(s)},_t=s=>({added(e){e[s]=!0},removed(e){e[s]=!1}}),Sn=s=>({added(e,t){e[s]=t}}),mt={checked:_t(\"checked\"),selected:_t(\"selected\"),value:Sn(\"value\"),autofocus:{added(s){queueMicrotask(()=>{s.focus?.()})}},autoplay:{added(s){try{s.play?.()}catch(e){console.error(e)}}}};var gt=new WeakMap;async function bt(s){let e=[];for(let r of y().querySelectorAll(\"link[rel=stylesheet], style\"))r.sheet||e.push(new Promise((n,o)=>{r.addEventListener(\"load\",n),r.addEventListener(\"error\",o)}));if(await Promise.allSettled(e),!s.host.isConnected)return[];s.adoptedStyleSheets=s.host.getRootNode().adoptedStyleSheets;let t=[];for(let r of y().styleSheets)try{s.adoptedStyleSheets.push(r)}catch{try{let n=gt.get(r);if(!n){n=new CSSStyleSheet;for(let o of r.cssRules)n.insertRule(o.cssText,n.cssRules.length);gt.set(r,n)}s.adoptedStyleSheets.push(n)}catch{let n=r.ownerNode.cloneNode();s.prepend(n),t.push(n)}}return t}var X=class extends Event{constructor(e,t,r){super(\"context-request\",{bubbles:!0,composed:!0}),this.context=e,this.callback=t,this.subscribe=r}};var wt=0,yt=1,kt=2,vt=3,Y=0,Et=1,jt=2,Z=3,Ct=4;var he=class extends HTMLElement{static get observedAttributes(){return[\"route\",\"method\"]}#r;#e=\"ws\";#n=null;#t=null;#i=[];#s;#o=new Set;#h=new Set;#u=!1;#c=[];#l=new Map;#a=new Set;#m=new MutationObserver(e=>{let t=[];for(let r of e){if(r.type!==\"attributes\")continue;let n=r.attributeName;(!this.#u||this.#o.has(n))&&t.push([n,this.getAttribute(n)])}if(t.length===1){let[r,n]=t[0];this.#t?.send({kind:Y,name:r,value:n})}else t.length?this.#t?.send({kind:Z,messages:t.map(([r,n])=>({kind:Y,name:r,value:n}))}):this.#c.push(...t)});constructor(){super(),this.internals=this.attachInternals(),this.#m.observe(this,{attributes:!0})}connectedCallback(){for(let e of this.attributes)this.#c.push([e.name,e.value])}attributeChangedCallback(e,t,r){switch(e){case(t!==r&&\"route\"):{this.#n=new URL(r,location.href),this.#f();return}case\"method\":{let n=r.toLowerCase();if(n==this.#e)return;[\"ws\",\"sse\",\"polling\"].includes(n)&&(this.#e=n,this.#e==\"ws\"&&(this.#n.protocol==\"https:\"&&(this.#n.protocol=\"wss:\"),this.#n.protocol==\"http:\"&&(this.#n.protocol=\"ws:\")),this.#f());return}}}async messageReceivedCallback(e){switch(e.kind){case wt:{for(this.#r??=this.attachShadow({mode:e.open_shadow_root?\"open\":\"closed\"});this.#r.firstChild;)this.#r.firstChild.remove();let t=(i,l,c,u)=>{let $=this.#p(i,u??[]);return{kind:Et,path:l,name:c,event:$}},r=(i,l)=>{this.#t?.send(l)};this.#s=new D(this.#r,t,r),this.#o=new Set(e.observed_attributes);let o=this.#c.filter(([i])=>this.#o.has(i)).map(([i,l])=>({kind:Y,name:i,value:l}));this.#c=[],this.#h=new Set(e.observed_properties);for(let i of this.#h)Object.defineProperty(this,i,{get(){return this[`_${i}`]},set(l){this[`_${i}`]=l,this.#t?.send({kind:jt,name:i,value:l})}});for(let[i,l]of Object.entries(e.provided_contexts))this.provide(i,l);for(let i of[...new Set(e.requested_contexts)])this.dispatchEvent(new X(i,(l,c)=>{this.#t?.send({kind:Ct,key:i,value:l}),this.#a.add(c)}));o.length&&this.#t.send({kind:Z,messages:o}),e.will_adopt_styles&&await this.#x(),this.#r.addEventListener(\"context-request\",i=>{if(!i.context||!i.callback||!this.#l.has(i.context))return;i.stopImmediatePropagation();let l=this.#l.get(i.context);if(i.subscribe){let c=new WeakRef(i.callback),u=()=>{l.subscribers=l.subscribers.filter($=>$!==c)};l.subscribers.push([c,u]),i.callback(l.value,u)}else i.callback(l.value)}),this.#s.mount(e.vdom),this.dispatchEvent(new CustomEvent(\"lustre:mount\"));break}case yt:{this.#s.push(e.patch);break}case kt:{this.dispatchEvent(new CustomEvent(e.name,{detail:e.data}));break}case vt:{this.provide(e.key,e.value);break}}}disconnectedCallback(){for(let e of this.#a)e();this.#a.clear()}provide(e,t){if(!this.#l.has(e))this.#l.set(e,{value:t,subscribers:[]});else{let r=this.#l.get(e);r.value=t;for(let n=r.subscribers.length-1;n>=0;n--){let[o,i]=r.subscribers[n],l=o.deref();if(!l){r.subscribers.splice(n,1);continue}l(t,i)}}}#f(){if(!this.#n||!this.#e)return;this.#t&&this.#t.close();let n={onConnect:()=>{this.#u=!0,this.dispatchEvent(new CustomEvent(\"lustre:connect\"),{detail:{route:this.#n,method:this.#e}})},onMessage:o=>{this.messageReceivedCallback(o)},onClose:()=>{this.#u=!1,this.dispatchEvent(new CustomEvent(\"lustre:close\",{detail:{route:this.#n,method:this.#e}}))}};switch(this.#e){case\"ws\":this.#t=new _e(this.#n,n);break;case\"sse\":this.#t=new me(this.#n,n);break;case\"polling\":this.#t=new xe(this.#n,n);break}}async#x(){for(;this.#i.length;)this.#i.pop().remove(),this.#r.firstChild.remove();this.#i=await bt(this.#r)}#p(e,t=[]){let r={};(e.type===\"input\"||e.type===\"change\")&&t.push(\"target.value\"),e.type===\"submit\"&&t.push(\"detail.formData\");for(let n of t){let o=n.split(\".\");for(let i=0,l=e,c=r;i<o.length;i++){if(i===o.length-1){c[o[i]]=l[o[i]];break}c=c[o[i]]??={},l=l[o[i]]}}return r}},_e=class{#r;#e;#n=!1;#t=[];#i;#s;#o;constructor(e,{onConnect:t,onMessage:r,onClose:n}){this.#r=e,this.#e=new WebSocket(this.#r),this.#i=t,this.#s=r,this.#o=n,this.#e.onopen=()=>{this.#i()},this.#e.onmessage=({data:o})=>{try{this.#s(JSON.parse(o))}finally{this.#t.length?this.#e.send(JSON.stringify({kind:Z,messages:this.#t})):this.#n=!1,this.#t=[]}},this.#e.onclose=()=>{this.#o()}}send(e){if(this.#n||this.#e.readyState!==WebSocket.OPEN){this.#t.push(e);return}else this.#e.send(JSON.stringify(e)),this.#n=!0}close(){this.#e.close()}},me=class{#r;#e;#n;#t;#i;constructor(e,{onConnect:t,onMessage:r,onClose:n}){this.#r=e,this.#e=new EventSource(this.#r),this.#n=t,this.#t=r,this.#i=n,this.#e.onopen=()=>{this.#n()},this.#e.onmessage=({data:o})=>{try{this.#t(JSON.parse(o))}catch{}}}send(e){}close(){this.#e.close(),this.#i()}},xe=class{#r;#e;#n;#t;#i;#s;constructor(e,{onConnect:t,onMessage:r,onClose:n,...o}){this.#r=e,this.#t=t,this.#i=r,this.#s=n,this.#e=o.interval??5e3,this.#o().finally(()=>{this.#t(),this.#n=setInterval(()=>this.#o(),this.#e)})}async send(e){}close(){clearInterval(this.#n),this.#s()}#o(){return fetch(this.#r).then(e=>e.json()).then(this.#i).catch(console.error)}};customElements.define(\"lustre-server-component\",he);export{he as ServerComponent};",
  );
}

/**
 * The `route` attribute tells the client runtime what route it should use to
 * set up the WebSocket connection to the server. Whenever this attribute is
 * changed (by a clientside Lustre app, for example), the client runtime will
 * destroy the current connection and set up a new one.
 */
export function route(path) {
  return attribute("route", path);
}

/**
 *
 */
export function method(value) {
  return attribute(
    "method",
    (() => {
      if (value instanceof WebSocket) {
        return "ws";
      } else if (value instanceof ServerSentEvents) {
        return "sse";
      } else {
        return "polling";
      }
    })(),
  );
}

/**
 * Properties of a JavaScript event object are typically not serialisable. This
 * means if we want to send them to the server we need to make a copy of any
 * fields we want to decode first.
 *
 * This attribute tells Lustre what properties to include from an event. Properties
 * can come from nested fields by using dot notation. For example, you could include
 * the
 * `id` of the target `element` by passing `["target.id"]`.
 *
 * ```gleam
 * import gleam/dynamic/decode
 * import lustre/element.{type Element}
 * import lustre/element/html
 * import lustre/event
 * import lustre/server_component
 *
 * pub fn custom_button(on_click: fn(String) -> msg) -> Element(msg) {
 *   let handler = fn(event) {
 *     use id <- decode.at(["target", "id"], decode.string)
 *     decode.success(on_click(id))
 *   }
 *
 *   html.button(
 *     [server_component.include(["target.id"]), event.on("click", handler)],
 *     [html.text("Click me!")],
 *   )
 * }
 * ```
 */
export function include(event, properties) {
  if (event instanceof Event) {
    return new Event(
      event.kind,
      event.name,
      event.handler,
      properties,
      event.prevent_default,
      event.stop_propagation,
      event.debounce,
      event.throttle,
    );
  } else {
    return event;
  }
}

/**
 * Recover the `Subject` of the server component runtime so that it can be used
 * in supervision trees or passed to other processes. If you want to hand out
 * different `Subject`s to send messages to your application, take a look at the
 * [`select`](#select) effect.
 *
 * > **Note**: this function is not available on the JavaScript target.
 *
 * Recover the `Pid` of the server component runtime so that it can be used in
 * supervision trees or passed to other processes. If you want to hand out
 * different `Subject`s to send messages to your application, take a look at the
 * [`select`](#select) effect.
 *
 * > **Note**: this function is not available on the JavaScript target.
 *
 * Register a `Subject` to receive messages and updates from Lustre's server
 * component runtime. The process that owns this will be monitored and the
 * subject will be gracefully removed if the process dies.
 *
 * > **Note**: if you are developing a server component for the JavaScript runtime,
 * > you should use [`register_callback`](#register_callback) instead.
 */
export function register_subject(client) {
  return new $runtime.ClientRegisteredSubject(client);
}

/**
 * Deregister a `Subject` to stop receiving messages and updates from Lustre's
 * server component runtime. The subject should first have been registered with
 * [`register_subject`](#register_subject) otherwise this will do nothing.
 */
export function deregister_subject(client) {
  return new $runtime.ClientDeregisteredSubject(client);
}

/**
 * Register a callback to be called whenever the server component runtime
 * produces a message. Avoid using anonymous functions with this function, as
 * they cannot later be removed using [`deregister_callback`](#deregister_callback).
 *
 * > **Note**: server components running on the Erlang target are **strongly**
 * > encouraged to use [`register_subject`](#register_subject) instead of this
 * > function.
 */
export function register_callback(callback) {
  return new $runtime.ClientRegisteredCallback(callback);
}

/**
 * Deregister a callback to be called whenever the server component runtime
 * produces a message. The callback to remove is determined by function equality
 * and must be the same function that was passed to [`register_callback`](#register_callback).
 *
 * > **Note**: server components running on the Erlang target are **strongly**
 * > encouraged to use [`register_subject`](#register_subject) instead of this
 * > function.
 */
export function deregister_callback(callback) {
  return new $runtime.ClientDeregisteredCallback(callback);
}

/**
 * Instruct any connected clients to emit a DOM event with the given name and
 * data. This lets your server component communicate to the frontend the same way
 * any other HTML elements do: you might emit a `"change"` event when some part
 * of the server component's state changes, for example.
 *
 * This is a real DOM event and any JavaScript on the page can attach an event
 * listener to the server component element and listen for these events.
 */
export function emit(event, data) {
  return $effect.event(event, data);
}

/**
 * On the Erlang target, Lustre's server component runtime is an OTP
 * [actor](https://hexdocs.pm/gleam_otp/gleam/otp/actor.html) that can be
 * communicated with using the standard process API and the `Subject` returned
 * when starting the server component.
 *
 * Sometimes, you might want to hand a different `Subject` to a process to restrict
 * the type of messages it can send or to distinguish messages from different
 * sources from one another. The `select` effect creates a fresh `Subject` each
 * time it is run. By returning a `Selector` you can teach the Lustre server
 * component runtime how to listen to messages from this `Subject`.
 *
 * The `select` effect also gives you the dispatch function passed to `effect.from`.
 * This is useful in case you want to store the provided `Subject` in your model
 * for later use. For example you may subscribe to a pubsub service and later use
 * that same `Subject` to unsubscribe.
 *
 * > **Note**: This effect does nothing on the JavaScript runtime, where `Subject`s
 * > and `Selector`s don't exist, and is the equivalent of returning `effect.none()`.
 */
export function select(sel) {
  return $effect.select(sel);
}

/**
 * The server component client runtime sends JSON-encoded messages for the server
 * runtime to execute. Because your own WebSocket server sits between the two
 * parts of the runtime, you need to decode these actions and pass them to the
 * server runtime yourself.
 */
export function runtime_message_decoder() {
  return $decode.map(
    $transport.server_message_decoder(),
    (var0) => { return new $runtime.ClientDispatchedMessage(var0); },
  );
}

/**
 * Encode a message you can send to the client runtime to respond to. The server
 * component runtime will send messages to any registered clients to instruct
 * them to update their DOM or emit events, for example.
 *
 * Because your WebSocket server sits between the two parts of the runtime, you
 * need to encode these actions and send them to the client runtime yourself.
 */
export function client_message_to_json(message) {
  return $transport.client_message_to_json(message);
}
