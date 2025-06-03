// 制作物
const projects = [
  {
    title: "xxxxアプリ",
    description: "TBD",
    url: "https://Mineyu-GH.github.io/"
  },
  {
    title: "xxxxアプリ",
    description: "TBD",
    url: "https://Mineyu-GH.github.io/S"
  }
];

const container = document.getElementById("projects");

projects.forEach(project => {
  const col = document.createElement("div");
  col.className = "col-md-6";

  col.innerHTML = `
    <div class="card h-100 shadow-sm">
      <div class="card-body">
        <h5 class="card-title">${project.title}</h5>
        <p class="card-text">${project.description}</p>
        <a href="${project.url}" class="btn btn-primary" target="_blank">見る</a>
      </div>
    </div>
  `;

  container.appendChild(col);
});
