(function () {
    const ctx = window.EBS_CONTEXT || '';
    const DATA_BASE = `${ctx}/data`;

    /* ── Boot: load labs into dropdown, then render first lab ── */
    window.addEventListener('DOMContentLoaded', async () => {
        try {
            const res  = await fetch(`${DATA_BASE}/labs.json`);
            const labs = await res.json();
            const select = document.getElementById('labSelect');
            if (!select) return;

            // Clear any existing options except the placeholder
            while (select.options.length > 1) select.remove(1);

            labs.forEach(lab => {
                const opt = document.createElement('option');
                opt.value       = lab.id;
                opt.textContent = lab.name;
                select.appendChild(opt);
            });

            // Auto-select and render first lab
            if (labs.length > 0) {
                select.value = String(labs[0].id);
                loadSeats();
            }
        } catch (err) {
            showError('Failed to load labs. Make sure GlassFish is running.');
        }
    });

    /* ── loadSeats: called by onchange and on boot ── */
    window.loadSeats = async function loadSeats() {
        const select    = document.getElementById('labSelect');
        const labId     = select.value;
        const container = document.getElementById('seat-map-container');
        const labName   = document.getElementById('lab-name');

        if (!labId) {
            container.innerHTML = '<p id="placeholder-text">Please select a lab to view the seat map.</p>';
            labName.textContent  = 'Select a Lab';
            return;
        }

        container.innerHTML = '<p class="loading-text">Loading seats...</p>';

        try {
            // Each lab can have its own seat file: seats_1.json, seats_2.json …
            const res   = await fetch(`${DATA_BASE}/seats_${labId}.json`);
            const seats = await res.json();

            const selectedOption = select.selectedOptions[0];
            const name           = selectedOption ? selectedOption.textContent.trim() : '';
            labName.textContent  = `${name} — Seat Map`;

            if (name.toUpperCase().includes('LG02')) {
                buildLG02Layout(container, seats);
            } else {
                buildGenericLayout(container, seats);
            }
        } catch (err) {
            showError('Failed to load seats for this lab.');
        }
    };

    /* ── LG02 physical layout ──────────────────────────────── */
    function buildLG02Layout(container, seats) {
        const seatMap = {};
        seats.forEach(s => { seatMap[s.seatLabel] = s; });

        const labBox = el('div', 'lab-boundary');

        const entrance = el('div', 'entrance-label');
        entrance.textContent = 'Entrance';
        labBox.appendChild(entrance);

        /* ─ inner row: [walkway | center seats | walkway | wall seats] ─ */
        const inner = el('div', 'lab-inner');

        inner.appendChild(el('div', 'walk-col'));   // left aisle

        const center = el('div', 'center-rows');
        center.appendChild(makeRow(['PC-01','PC-02','PC-03','PC-04','PC-05'], seatMap, 'down'));

        const b2b = el('div', 'back-to-back');
        b2b.appendChild(makeRow(['PC-06','PC-07','PC-08','PC-09','PC-10'], seatMap, 'down'));
        b2b.appendChild(makeRow(['PC-11','PC-12','PC-13','PC-14','PC-15'], seatMap, 'up'));
        center.appendChild(b2b);

        center.appendChild(makeRow(['PC-16','PC-17','PC-18','PC-19','PC-20'], seatMap, 'down'));
        inner.appendChild(center);

        inner.appendChild(el('div', 'walk-col'));   // right aisle

        /* wall seats on the far right */
        const wallCol = el('div', 'wall-col');
        ['PC-28','PC-29','PC-30','PC-31','PC-32','PC-33','PC-34','PC-35','PC-36']
            .forEach(lbl => wallCol.appendChild(createWallSeat(seatMap[lbl] || { seatLabel: lbl, status: 'available' })));
        inner.appendChild(wallCol);

        labBox.appendChild(inner);

        /* bottom row */
        const bottomRow = el('div', 'bottom-row');
        ['PC-21','PC-22','PC-23','PC-24','PC-25','PC-26','PC-27']
            .forEach(lbl => bottomRow.appendChild(createSeat(seatMap[lbl] || { seatLabel: lbl, status: 'available' }, 'down')));
        labBox.appendChild(bottomRow);

        container.innerHTML = '';
        container.appendChild(labBox);
    }

    /* ── Generic grid layout for other labs ────────────────── */
    function buildGenericLayout(container, seats) {
        if (!seats.length) { showError('No seats found for this lab.'); return; }

        const maxCol = Math.max(...seats.map(s => s.colPos));
        const grid   = el('div', 'seat-grid');
        grid.style.gridTemplateColumns = `repeat(${maxCol}, 68px)`;

        const rows = {};
        seats.forEach(s => {
            if (!rows[s.rowPos]) rows[s.rowPos] = [];
            rows[s.rowPos].push(s);
        });

        Object.keys(rows).sort((a, b) => a - b).forEach(rowNum => {
            const rowSeats = rows[rowNum];
            for (let col = 1; col <= maxCol; col++) {
                const seat = rowSeats.find(s => s.colPos === col);
                grid.appendChild(seat ? createSeat(seat, 'up') : el('div', 'seat-gap'));
            }
        });

        container.innerHTML = '';
        container.appendChild(grid);
    }

    /* ── Helpers ────────────────────────────────────────────── */
    function makeRow(labels, seatMap, direction) {
        const row = el('div', 'seat-row');
        labels.forEach(lbl =>
            row.appendChild(createSeat(seatMap[lbl] || { seatLabel: lbl, status: 'available' }, direction))
        );
        return row;
    }

    function createSeat(seat, direction) {
        const div = el('div', `seat ${normalizeStatus(seat.status)} facing-${direction || 'up'}`);

        const monitor = el('div', 'monitor');
        const stand   = el('div', 'monitor-stand');

        const label = el('span', 'seat-label');
        label.textContent = seat.seatLabel.replace('PC-', '');
        if (direction === 'down')  label.style.transform = 'rotate(180deg)';
        if (direction === 'left')  label.style.transform = 'rotate(90deg)';
        if (direction === 'right') label.style.transform = 'rotate(-90deg)';

        const tooltip = el('div', 'seat-tooltip');
        tooltip.textContent = `${seat.seatLabel} — ${capitalise(seat.status)}`;

        div.appendChild(monitor);
        div.appendChild(stand);
        div.appendChild(label);
        div.appendChild(tooltip);

        // Click to book (only available seats)
        if (normalizeStatus(seat.status) === 'available') {
            div.addEventListener('click', () => {
                const url = `${ctx}/student/booking?labId=1&seatId=${seat.id}`;
                window.location.href = url;
            });
        }

        return div;
    }

    function createWallSeat(seat) {
        const div = el('div', `seat ${normalizeStatus(seat.status)} wall-seat`);
        div.style.flexDirection  = 'row-reverse';
        div.style.justifyContent = 'center';
        div.style.gap            = '6px';

        const monitorWrap = el('div');
        monitorWrap.style.cssText = 'display:flex;flex-direction:column;align-items:center;justify-content:center;';
        monitorWrap.appendChild(el('div', 'monitor'));
        monitorWrap.appendChild(el('div', 'monitor-stand'));

        const label = el('span', 'seat-label');
        label.textContent = seat.seatLabel.replace('PC-', '');

        const tooltip = el('div', 'seat-tooltip');
        tooltip.textContent = `${seat.seatLabel} — ${capitalise(seat.status)}`;

        div.appendChild(monitorWrap);
        div.appendChild(label);
        div.appendChild(tooltip);

        if (normalizeStatus(seat.status) === 'available') {
            div.addEventListener('click', () => {
                window.location.href = `${ctx}/student/booking?labId=1&seatId=${seat.id}`;
            });
        }

        return div;
    }

    function normalizeStatus(status) {
        if (!status) return 'available';
        const s = status.toLowerCase().replace(/[\s_]/g, '-');
        if (s === 'in-use' || s === 'occupied') return 'in-use';
        if (s === 'unavailable' || s === 'broken') return 'unavailable';
        return 'available';
    }

    function capitalise(str) {
        if (!str) return '';
        return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
    }

    function el(tag, className) {
        const e = document.createElement(tag);
        if (className) e.className = className;
        return e;
    }

    function showError(msg) {
        const container = document.getElementById('seat-map-container');
        if (container) container.innerHTML = `<p class="error-text">${msg}</p>`;
    }
})();