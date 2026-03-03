function popup(msg, type="info") {
  try {
    if (typeof window.toast === "function") return window.toast(msg);
    if (window.kernelsu?.toast) return window.kernelsu.toast(msg);
    if (ksu?.toast) return ksu.toast(msg);
  } catch {}
  snackbar(msg);
}

function snackbar(msg) {
  const bar = document.getElementById("snackbar");
  bar.innerText = msg;
  bar.classList.add("show");
  clearTimeout(snackbar._t);
  snackbar._t = setTimeout(()=> bar.classList.remove("show"), 2400);
}

async function runShell(cmd) {
  return new Promise((res, rej)=>{
    if (!ksu?.exec) return rej("KSU not available");

    const cb = "cb_" + Date.now();
    window[cb] = (code, out, err)=>{
      delete window[cb];
      code===0 ? res(out||"") : rej(err||out||"Shell failed");
    };
    ksu.exec(cmd, "{}", cb);
  });
}

const CONFIG = "/data/adb/display/customize.txt";
const SERVICE = "/data/adb/modules/Kryptonite/service.sh";

async function loadConfig(){
  try {
    let txt = await runShell(`cat ${CONFIG}`);
    return {
      sat: txt.match(/saturation=([0-9.]+)/)?.[1] || "1.5",
      con: txt.match(/contrast=([0-9.]+)/)?.[1] || "0.7"
    };
  } catch {
    return { sat:"1.5", con:"0.7" };
  }
}

function updatePreview(){
  const s = satSlider.value;
  const c = conSlider.value;

  satValue.innerText = s;
  conValue.innerText = c;

  document.querySelectorAll(".pImg").forEach(i=>{
    i.style.filter = `saturate(${1 + (s-1)*0.4}) contrast(${1 + (c-1)*0.4})`;
  });


  localStorage.setItem("sat", s);
  localStorage.setItem("con", c);
}

async function applySettings(){
  const s = satSlider.value;
  const c = conSlider.value;

  popup("Applying...");

  const text =
    `saturation=${s}\n` +
    `contrast=${c}\n` +
    `reset=false\n`;

  await runShell(`echo -e "${text}" > ${CONFIG}`);
  await runShell(`sh ${SERVICE} &`);

  popup("Applied!", "success");
}

async function resetDefaults(){
  popup("Resetting...");
  await runShell(`echo -e "saturation=1.5\ncontrast=0.7\nreset=true" > ${CONFIG}`);
  await runShell(`sh ${SERVICE} &`);
  popup("Reset Complete!", "success");
}

function loadTheme(){
  const t = localStorage.getItem("theme") || "light";
  document.body.classList.toggle("dark", t==="dark");
}
function toggleTheme(){
  const newT = document.body.classList.contains("dark") ? "light" : "dark";
  localStorage.setItem("theme", newT);
  loadTheme();
  popup(newT==="dark"?"Dark Mode":"Light Mode");
}

function enableRipple(){
  document.querySelectorAll(".btn, .fab-toggle").forEach(btn=>{
    btn.addEventListener("click", e=>{
      const r = document.createElement("span");
      r.className = "ripple";
      const rect = btn.getBoundingClientRect();
      const size = Math.max(rect.width, rect.height);
      r.style.width = r.style.height = size+"px";
      r.style.left = (e.clientX - rect.left - size/2)+"px";
      r.style.top  = (e.clientY - rect.top - size/2)+"px";
      btn.appendChild(r);
      setTimeout(()=>r.remove(), 550);
    });
  });
}

let modal = document.getElementById("imgModal");
let modalPic = document.getElementById("imgModalPic");

document.addEventListener("click", e=>{
  if(e.target.classList.contains("pImg")){
    modalPic.src = e.target.src;
    modal.style.display = "flex";
    scale = 1;
    modalPic.style.transform = "scale(1)";
  } else if(e.target === modal){
    modal.style.display = "none";
  }
});

let scale = 1;
let startDist = 0;

function dist(e){
  let x = e.touches[0].clientX - e.touches[1].clientX;
  let y = e.touches[0].clientY - e.touches[1].clientY;
  return Math.hypot(x,y);
}

modalPic.addEventListener("touchmove", e=>{
  if(e.touches.length === 2){
    let d = dist(e);
    if(startDist === 0) startDist = d;
    scale = Math.min(4, Math.max(1, scale + (d - startDist)/300));
    modalPic.style.transform = `scale(${scale})`;
  }
});

modalPic.addEventListener("touchend", ()=>{
  startDist = 0;
});

document.addEventListener("DOMContentLoaded", async()=>{

  loadTheme();
  enableRipple();

  const cfg = await loadConfig();

  satSlider.value = localStorage.getItem("sat") || cfg.sat;
  conSlider.value = localStorage.getItem("con") || cfg.con;

  updatePreview();

  satSlider.oninput = updatePreview;
  conSlider.oninput = updatePreview;

  applyBtn.onclick = applySettings;
  resetBtn.onclick = resetDefaults;

  document.querySelector(".fab-toggle").onclick = toggleTheme;
});