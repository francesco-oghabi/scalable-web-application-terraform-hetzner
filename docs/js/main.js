// Smooth scrolling for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// Add active class to nav items on scroll
window.addEventListener('scroll', () => {
    const sections = document.querySelectorAll('section[id]');
    const navLinks = document.querySelectorAll('.nav-menu a[href^="#"]');

    let current = '';
    sections.forEach(section => {
        const sectionTop = section.offsetTop;
        const sectionHeight = section.clientHeight;
        if (scrollY >= (sectionTop - 200)) {
            current = section.getAttribute('id');
        }
    });

    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href') === '#' + current) {
            link.classList.add('active');
        }
    });
});

// Copy code to clipboard functionality
document.addEventListener('DOMContentLoaded', () => {
    const codeBlocks = document.querySelectorAll('.code-block');

    codeBlocks.forEach(block => {
        const button = document.createElement('button');
        button.className = 'copy-button';
        button.textContent = 'Copy';
        button.style.cssText = `
            position: absolute;
            top: 10px;
            right: 10px;
            background: rgba(255, 255, 255, 0.1);
            color: white;
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 5px 10px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
            transition: all 0.3s ease;
        `;

        block.style.position = 'relative';
        block.appendChild(button);

        button.addEventListener('click', () => {
            const code = block.querySelector('code').textContent;
            navigator.clipboard.writeText(code).then(() => {
                button.textContent = 'Copied!';
                button.style.background = 'rgba(16, 185, 129, 0.2)';
                setTimeout(() => {
                    button.textContent = 'Copy';
                    button.style.background = 'rgba(255, 255, 255, 0.1)';
                }, 2000);
            });
        });

        button.addEventListener('mouseenter', () => {
            button.style.background = 'rgba(255, 255, 255, 0.2)';
        });

        button.addEventListener('mouseleave', () => {
            if (button.textContent === 'Copy') {
                button.style.background = 'rgba(255, 255, 255, 0.1)';
            }
        });
    });
});

// Fade in animations on scroll
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, observerOptions);

// Apply fade-in effect to cards
document.addEventListener('DOMContentLoaded', () => {
    const cards = document.querySelectorAll('.feature-card, .component-detail, .comparison-item, .use-case-card, .component');

    cards.forEach(card => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        card.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(card);
    });
});
