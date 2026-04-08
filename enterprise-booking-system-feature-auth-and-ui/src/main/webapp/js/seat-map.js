(function () {
    const ctx = window.EBS_CONTEXT || '';
    const DATA_BASE = `${ctx}/data`;

    const STORAGE_KEY = 'ebs_student_bookings';
    let currentLabId = '';
    let currentLabName = '';
    let currentSelectedSeat = null;

    let availableSlots = [
        { id: 1, startHour: 8,  label: '08:00 – 10:30' },
        { id: 2, startHour: 10, label: '10:30 – 12:00' },
        { id: 3, startHour: 12, label: '12:30 – 14:00' },
        { id: 4, startHour: 14, label: '14:30 – 16:00' },
        { id: 5, startHour: 16, label: '16:30 – 18:00' },
        { id: 6, startHour: 18, label: '18:30 – 20:00' }
    ];

    window.addEventListener('DOMContentLoaded', async () => {
        ensureModal();
        await loadSlots();

        try {
            const res = await fetch(`${DATA_BASE}/labs.json`);
            const labs = await res.json();
            const select = document.getElementById('labSelect');
            if (!select) return;

            const existingValues = new Set(
                Array.from(select.options).map(opt => opt.value)
            );

            labs.forEach(lab => {
                if (!existingValues.has(String(lab.id))) {
                    const opt = document.createElement('option');
                    opt.value = lab.id;
                    opt.textContent = lab.name;
                    select.appendChild(opt);
                }
            });

            const params = new URLSearchParams(window.location.search);
            const queryLabId = params.get('labId');
            if (queryLabId) {
                select.value = queryLabId;
            }

            if (select.value) {
                loadSeats();
            }
        } catch (err) {
            showError('Failed to load labs.');
            console.error(err);
        }
    });

    async function loadSlots() {
        try {
            const res = await fetch(`${DATA_BASE}/timeslot.json`);
            if (!res.ok) {
                throw new Error('timeslot.json not found');
            }

            const slots = await res.json();
            if (Array.isArray(slots) && slots.length > 0) {
                availableSlots = slots;
            } else {
                throw new Error('timeslot.json is empty or invalid');
            }
        } catch (err) {
            console.warn('timeslot.json could not be loaded, using default slots.');
            console.error(err);
        }
    }

    window.loadSeats = async function loadSeats() {
        const labId = document.getElementById('labSelect').value;
        const container = document.getElementById('seat-map-container');
        const labName = document.getElementById('lab-name');

        currentLabId = labId || '';

        if (!labId) {
            container.innerHTML = '<p id="placeholder-text">Please select a lab to view the seat map.</p>';
            labName.textContent = 'Select a Lab';
            return;
        }

        container.innerHTML = '<p class="loading-text">Loading seats...</p>';

        try {
            const fileName = `seats_${labId}.json`;
            const res = await fetch(`${DATA_BASE}/${fileName}`);
            if (!res.ok) {
                throw new Error(`Could not load ${fileName}`);
            }

            const seats = await res.json();
            const selectedOption = document.getElementById('labSelect').selectedOptions[0];
            currentLabName = selectedOption ? selectedOption.textContent : `Lab ${labId}`;
            labName.textContent = `${currentLabName} — Seat Map`;

            const mergedSeats = applyBookingStateToSeats(seats, labId);

            if (currentLabName.trim().toUpperCase().includes('LG02')) {
                buildLG02Layout(container, mergedSeats);
            } else {
                buildGenericLayout(container, mergedSeats);
            }
        } catch (err) {
            console.error(err);
            showError('Failed to load seats for this lab.');
        }
    };

    function applyBookingStateToSeats(seats, labId) {
        const bookings = getStoredBookings();
        const today = todayString();

        return seats.map(seat => {
            const found = bookings.find(b =>
                String(b.labId) === String(labId) &&
                b.seatLabel === seat.seatLabel &&
                b.date === today
            );

            if (found) {
                return { ...seat, status: 'in-use' };
            }
            return seat;
        });
    }

    function buildLG02Layout(container, seats) {
        const seatMap = {};
        seats.forEach(s => { seatMap[s.seatLabel] = s; });

        const labBox = document.createElement('div');
        labBox.className = 'lab-boundary';

        const entrance = document.createElement('div');
        entrance.className = 'entrance-label';
        entrance.textContent = 'Entrance';
        labBox.appendChild(entrance);

        const inner = document.createElement('div');
        inner.className = 'lab-inner';

        const leftWalk = document.createElement('div');
        leftWalk.className = 'walk-col';
        inner.appendChild(leftWalk);

        const center = document.createElement('div');
        center.className = 'center-rows';
        center.appendChild(makeSeatRow(['PC-01','PC-02','PC-03','PC-04','PC-05'], seatMap, 'down'));

        const backToBack = document.createElement('div');
        backToBack.className = 'back-to-back';
        backToBack.appendChild(makeSeatRow(['PC-06','PC-07','PC-08','PC-09','PC-10'], seatMap, 'down'));
        backToBack.appendChild(makeSeatRow(['PC-11','PC-12','PC-13','PC-14','PC-15'], seatMap, 'up'));
        center.appendChild(backToBack);
        center.appendChild(makeSeatRow(['PC-16','PC-17','PC-18','PC-19','PC-20'], seatMap, 'down'));
        inner.appendChild(center);

        const rightWalk = document.createElement('div');
        rightWalk.className = 'walk-col';
        inner.appendChild(rightWalk);

        const wallCol = document.createElement('div');
        wallCol.className = 'wall-col';
        ['PC-28','PC-29','PC-30','PC-31','PC-32','PC-33','PC-34','PC-35','PC-36'].forEach(label => {
            wallCol.appendChild(createWallSeat(seatMap[label] || { seatLabel: label, status: 'available' }));
        });
        inner.appendChild(wallCol);
        labBox.appendChild(inner);

        const bottomRow = document.createElement('div');
        bottomRow.className = 'bottom-row';
        ['PC-21','PC-22','PC-23','PC-24','PC-25','PC-26','PC-27'].forEach(label => {
            bottomRow.appendChild(createSeat(seatMap[label] || { seatLabel: label, status: 'available' }, 'down'));
        });
        labBox.appendChild(bottomRow);

        container.innerHTML = '';
        container.appendChild(labBox);
    }

    function buildGenericLayout(container, seats) {
        const maxCol = Math.max(...seats.map(s => s.colPos));
        const grid = document.createElement('div');
        grid.className = 'seat-grid';
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
                if (seat) {
                    grid.appendChild(createSeat(seat, 'up'));
                } else {
                    const gap = document.createElement('div');
                    gap.className = 'seat-gap';
                    grid.appendChild(gap);
                }
            }
        });

        container.innerHTML = '';
        container.appendChild(grid);
    }

    function makeSeatRow(labels, seatMap, direction) {
        const row = document.createElement('div');
        row.className = 'seat-row';
        labels.forEach(label => {
            row.appendChild(createSeat(seatMap[label] || { seatLabel: label, status: 'available' }, direction));
        });
        return row;
    }

    function createSeat(seat, direction) {
        const statusClass = normalizeStatus(seat.status);
        const div = document.createElement('div');
        div.className = `seat ${statusClass} facing-${direction || 'up'}`;

        const monitor = document.createElement('div');
        monitor.className = 'monitor';

        const stand = document.createElement('div');
        stand.className = 'monitor-stand';

        const label = document.createElement('span');
        label.className = 'seat-label';
        label.textContent = seat.seatLabel.replace('PC-', '');
        label.style.display = 'inline-block';

        if (direction === 'down')  label.style.transform = 'rotate(180deg)';
        if (direction === 'left')  label.style.transform = 'rotate(90deg)';
        if (direction === 'right') label.style.transform = 'rotate(-90deg)';

        const tooltip = document.createElement('div');
        tooltip.className = 'seat-tooltip';
        tooltip.textContent = `${seat.seatLabel} — ${seat.status}`;

        div.appendChild(monitor);
        div.appendChild(stand);
        div.appendChild(label);
        div.appendChild(tooltip);

        if (statusClass === 'available') {
            div.addEventListener('click', function (e) {
                e.preventDefault();
                e.stopPropagation();
                openBookingModal(seat);
            });
        }

        return div;
    }

    function createWallSeat(seat) {
        const statusClass = normalizeStatus(seat.status);
        const div = document.createElement('div');
        div.className = `seat ${statusClass} wall-seat`;

        div.style.flexDirection = 'row-reverse';
        div.style.justifyContent = 'center';
        div.style.gap = '6px';

        const monitorWrap = document.createElement('div');
        monitorWrap.style.cssText = 'display:flex; flex-direction:column; align-items:center; justify-content:center;';

        const monitor = document.createElement('div');
        monitor.className = 'monitor';

        const stand = document.createElement('div');
        stand.className = 'monitor-stand';

        monitorWrap.appendChild(monitor);
        monitorWrap.appendChild(stand);

        const label = document.createElement('span');
        label.className = 'seat-label';
        label.textContent = seat.seatLabel.replace('PC-', '');

        const tooltip = document.createElement('div');
        tooltip.className = 'seat-tooltip';
        tooltip.textContent = `${seat.seatLabel} — ${seat.status}`;

        div.appendChild(monitorWrap);
        div.appendChild(label);
        div.appendChild(tooltip);

        if (statusClass === 'available') {
            div.addEventListener('click', function (e) {
                e.preventDefault();
                e.stopPropagation();
                openBookingModal(seat);
            });
        }

        return div;
    }

    function normalizeStatus(status) {
        if (!status) return 'available';
        const s = status.toLowerCase().replace(/[\s_]/g, '-');
        if (s === 'in-use' || s === 'occupied' || s === 'booked') return 'in-use';
        if (s === 'unavailable' || s === 'broken' || s === 'maintenance') return 'unavailable';
        return 'available';
    }

    function ensureModal() {
        if (document.getElementById('seatBookingModal')) return;

        const modal = document.createElement('div');
        modal.id = 'seatBookingModal';
        modal.style.cssText = `
            display:none;
            position:fixed;
            inset:0;
            background:rgba(15,23,42,0.45);
            z-index:3000;
            align-items:center;
            justify-content:center;
            padding:20px;
        `;

        modal.innerHTML = `
            <div style="
                background:#ffffff;
                width:100%;
                max-width:420px;
                border-radius:16px;
                border:1px solid #e2e8f0;
                box-shadow:0 20px 50px rgba(0,0,0,0.18);
                padding:22px;
            ">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;">
                    <h3 style="font-size:18px;color:#1e293b;margin:0;">Book PC</h3>
                    <button id="seatBookingCloseBtn" type="button" style="
                        border:none;background:none;font-size:20px;cursor:pointer;color:#64748b;
                    ">&times;</button>
                </div>

                <div style="font-size:14px;color:#475569;line-height:1.7;margin-bottom:14px;">
                    <div><strong>Lab:</strong> <span id="bookingLabName"></span></div>
                    <div><strong>PC:</strong> <span id="bookingSeatLabel"></span></div>
                    <div><strong>Date:</strong> <span id="bookingDate"></span></div>
                </div>

                <label for="bookingSlotSelect" style="display:block;font-size:13px;font-weight:600;color:#475569;margin-bottom:8px;">
                    Time Slot
                </label>
                <select id="bookingSlotSelect" style="
                    width:100%;
                    padding:10px 12px;
                    border:1.5px solid #e2e8f0;
                    border-radius:10px;
                    font-size:14px;
                    margin-bottom:16px;
                    outline:none;
                ">
                    <option value="">-- Select a time slot --</option>
                </select>

                <div id="bookingMsg" style="display:none;font-size:13px;margin-bottom:14px;"></div>

                <div style="display:flex;gap:10px;justify-content:flex-end;">
                    <button id="cancelBookingBtn" type="button" style="
                        padding:10px 14px;
                        border-radius:10px;
                        border:1px solid #e2e8f0;
                        background:#fff;
                        cursor:pointer;
                    ">Cancel</button>
                    <button id="confirmBookingBtn" type="button" style="
                        padding:10px 14px;
                        border-radius:10px;
                        border:none;
                        background:#2563eb;
                        color:#fff;
                        cursor:pointer;
                        font-weight:600;
                    ">Confirm Booking</button>
                </div>
            </div>
        `;

        document.body.appendChild(modal);

        modal.addEventListener('click', function (e) {
            if (e.target === modal) closeBookingModal();
        });

        document.getElementById('seatBookingCloseBtn').addEventListener('click', closeBookingModal);
        document.getElementById('cancelBookingBtn').addEventListener('click', closeBookingModal);
        document.getElementById('confirmBookingBtn').addEventListener('click', confirmSeatBooking);
    }

    function openBookingModal(seat) {
        currentSelectedSeat = seat;

        document.getElementById('bookingLabName').textContent = currentLabName || `Lab ${currentLabId}`;
        document.getElementById('bookingSeatLabel').textContent = seat.seatLabel;
        document.getElementById('bookingDate').textContent = todayString();

        const select = document.getElementById('bookingSlotSelect');
        select.innerHTML = '<option value="">-- Select a time slot --</option>';

        const bookings = getStoredBookings();
        const today = todayString();

        const seatBookings = bookings.filter(b =>
            String(b.labId) === String(currentLabId) &&
            b.seatLabel === seat.seatLabel &&
            b.date === today
        );

        availableSlots.forEach(slot => {
            const taken = seatBookings.some(b => String(b.slotId) === String(slot.id));
            const opt = document.createElement('option');
            opt.value = slot.id;
            opt.textContent = taken ? `${slot.label} (Booked)` : slot.label;
            opt.disabled = taken;
            select.appendChild(opt);
        });

        hideBookingMsg();
        document.getElementById('seatBookingModal').style.display = 'flex';
    }

    function closeBookingModal() {
        document.getElementById('seatBookingModal').style.display = 'none';
        currentSelectedSeat = null;
        hideBookingMsg();
    }

    function confirmSeatBooking() {
        if (!currentSelectedSeat) return;

        const select = document.getElementById('bookingSlotSelect');
        const slotId = select.value;

        if (!slotId) {
            showBookingMsg('Please choose a time slot first.', '#dc2626');
            return;
        }

        const slot = availableSlots.find(s => String(s.id) === String(slotId));
        if (!slot) {
            showBookingMsg('Invalid slot selected.', '#dc2626');
            return;
        }

        const bookings = getStoredBookings();

        const alreadyTaken = bookings.some(b =>
            String(b.labId) === String(currentLabId) &&
            b.seatLabel === currentSelectedSeat.seatLabel &&
            b.date === todayString() &&
            String(b.slotId) === String(slotId)
        );

        if (alreadyTaken) {
            showBookingMsg('That PC is already booked for that slot.', '#dc2626');
            return;
        }

        const booking = {
            id: Date.now(),
            labId: String(currentLabId),
            labName: currentLabName,
            seatId: currentSelectedSeat.id,
            seatLabel: currentSelectedSeat.seatLabel,
            slotId: slot.id,
            slotLabel: slot.label,
            date: todayString(),
            status: 'CONFIRMED',
            createdAt: new Date().toISOString()
        };

        bookings.push(booking);
        localStorage.setItem(STORAGE_KEY, JSON.stringify(bookings));

        closeBookingModal();
        loadSeats();
        alert(`Booked ${booking.seatLabel} for ${booking.slotLabel}`);
    }

    function getStoredBookings() {
        try {
            return JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]');
        } catch (e) {
            return [];
        }
    }

    function todayString() {
        const d = new Date();
        const yyyy = d.getFullYear();
        const mm = String(d.getMonth() + 1).padStart(2, '0');
        const dd = String(d.getDate()).padStart(2, '0');
        return `${yyyy}-${mm}-${dd}`;
    }

    function showBookingMsg(msg, color) {
        const box = document.getElementById('bookingMsg');
        box.style.display = 'block';
        box.style.color = color;
        box.textContent = msg;
    }

    function hideBookingMsg() {
        const box = document.getElementById('bookingMsg');
        box.style.display = 'none';
        box.textContent = '';
    }

    function showError(msg) {
        const container = document.getElementById('seat-map-container');
        if (container) container.innerHTML = `<p class="error-text">${msg}</p>`;
    }
})();