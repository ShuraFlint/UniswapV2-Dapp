# var 是历史遗留设计，let 是现代 JS 的正确方式。
## 1️⃣ 作用域不同（最重要）🔥
var —— 函数作用域
```js
function test() {
  if (true) {
    var a = 10;
  }
  console.log(a); // ✅ 10
}

let —— 块级作用域
function test() {
  if (true) {
    let b = 20;
  }
  console.log(b); // ❌ ReferenceError
}


👉 {} 对 let 生效，对 var 不生效

2️⃣ 变量提升（Hoisting）差异 ⚠️
var 会提升（值是 undefined）
console.log(x); // undefined
var x = 5;

let 也提升，但不可访问（TDZ）
console.log(y); // ❌ ReferenceError
let y = 5;


📌 let 在声明前处于 暂时性死区（TDZ）

3️⃣ 是否允许重复声明 🚫
var 允许
var a = 1;
var a = 2; // ✅ 不报错

let 不允许
let b = 1;
let b = 2; // ❌ SyntaxError


👉 let 更安全

4️⃣ 是否挂到全局对象 🌍
全局 var
var x = 10;
console.log(window.x); // 10

全局 let
let y = 20;
console.log(window.y); // undefined


👉 var 会污染全局对象
👉 let 不会

5️⃣ for 循环中的经典区别（超级常见）🔥
var
for (var i = 0; i < 3; i++) {
  setTimeout(() => console.log(i), 100);
}
// 输出：3 3 3

let
for (let i = 0; i < 3; i++) {
  setTimeout(() => console.log(i), 100);
}
// 输出：0 1 2


👉 let 为每次循环创建独立作用域