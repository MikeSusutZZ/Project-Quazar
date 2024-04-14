// For the death screen visuals
let Hooks = {};
Hooks.FadeIn = {
    mounted() {
      console.log("FadeIn mounted, applying styles...");
      this.el.style.opacity = 0;
      setTimeout(() => {
        this.el.style.transition = 'opacity 5s ease-in-out';
        this.el.style.opacity = 1;
        console.log("Styles applied, opacity should be 1 now.");
      }, 100);
    }
  };
  

export default Hooks;
