// Sidebar navigation control
document.addEventListener('DOMContentLoaded', function() {
    // Get all part links (main navigation items)
    const partLinks = document.querySelectorAll('.sidebar nav > ul > li > a');
    
    // Initially collapse all sections except the current one
    function initializeSidebar() {
        const currentPath = window.location.pathname;
        
        partLinks.forEach(link => {
            const parentLi = link.parentElement;
            const subList = parentLi.querySelector('ul');
            
            if (subList) {
                // Check if any child is currently active
                const activeChild = subList.querySelector('.active');
                
                if (!activeChild) {
                    // Collapse if no active child
                    parentLi.classList.remove('active');
                    subList.style.maxHeight = '0';
                } else {
                    // Expand if has active child
                    parentLi.classList.add('active');
                    subList.style.maxHeight = subList.scrollHeight + 'px';
                }
            }
        });
    }
    
    // Toggle section on click
    partLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            const parentLi = this.parentElement;
            const subList = parentLi.querySelector('ul');
            
            if (subList) {
                e.preventDefault();
                
                // Close other sections
                partLinks.forEach(otherLink => {
                    if (otherLink !== this) {
                        const otherParentLi = otherLink.parentElement;
                        const otherSubList = otherParentLi.querySelector('ul');
                        if (otherSubList) {
                            otherParentLi.classList.remove('active');
                            otherSubList.style.maxHeight = '0';
                        }
                    }
                });
                
                // Toggle current section
                if (parentLi.classList.contains('active')) {
                    parentLi.classList.remove('active');
                    subList.style.maxHeight = '0';
                } else {
                    parentLi.classList.add('active');
                    subList.style.maxHeight = subList.scrollHeight + 'px';
                }
            }
        });
    });
    
    // Initialize on load
    initializeSidebar();
    
    // Re-initialize on navigation (for SPA-like behavior)
    window.addEventListener('popstate', initializeSidebar);
});
