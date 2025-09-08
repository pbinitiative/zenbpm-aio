<template>
  <q-page class="q-pa-md">
    <q-form class="q-gutter-md" @submit="submit">
      <!-- Basic information -->
      <q-card-section>
        <div class="text-h5 q-mb-md">Basic information</div>
        <div class="row q-col-gutter-md">
          <div class="col-4">
            <label>Contract ID</label><q-input filled v-model="formData.claim.contractId" required />
          </div>
          <div class="col-4">
            <label>Name and Surname</label><q-input filled v-model="formData.claim.name" required />
          </div>
          <div class="col-4"><label>Address</label><q-input filled v-model="formData.claim.address" required /></div>
          <div class="col-4">
            <label>Phone number</label><q-input filled v-model="formData.input.phoneNumber" required />
          </div>
          <div class="col-4"><label>Email</label><q-input filled v-model="formData.claim.email" /></div>
        </div>
      </q-card-section>

      <!-- Incident information -->
      <q-card-section>
        <div class="text-h5 q-mb-md">Incident information</div>
        <div class="row q-col-gutter-md">
          <div class="col-6">
            <label>Date of incident</label><q-input filled v-model="formData.claim.date" type="date" required />
          </div>
          <div class="col-6">
            <label>Place of incident</label><q-input filled v-model="formData.claim.placeOfDamage" required />
          </div>
          <div class="col-6">
            <label>Cause of incident</label><q-input filled v-model="formData.claim.damageCause" required />
          </div>
          <div class="col-6">
            <label>Estimated damage</label
            ><q-input filled v-model="formData.claim.amountOfDamage" type="number" required />
          </div>
          <div class="col-6">
            <label>Final damage</label
            ><q-input filled v-model="formData.claim.finalAmountOfDamage" type="number" required />
          </div>
          <div class="col-12">
            <label>Description of incident</label
            ><q-input filled type="textarea" v-model="formData.claim.description" required />
          </div>
        </div>
      </q-card-section>

      <!-- Insured property -->
      <q-card-section>
        <div class="text-h5 q-mb-md">Insured property</div>
        <div class="row q-col-gutter-md">
          <div class="col-6">
            <label>Type of insurance</label
            ><q-select filled v-model="formData.claim.insuranceType" :options="insuranceOptions" required />
          </div>
          <div class="col-6">
            <label>Description of damaged property</label
            ><q-input filled v-model="formData.claim.descriptionOfDamagedProperty" required />
          </div>
        </div>
      </q-card-section>

      <div class="row">
        <!-- Attachments -->
        <q-card-section class="col-6">
          <div class="text-h5 q-mb-md">Attachments</div>
          <q-table :rows="formData.files" :columns="columns" row-key="id" @row-click="openDialog" />
          <q-dialog v-model="showDialog" :maximized="$q.screen.lt.md">
            <q-card class="no-scroll" style="min-width: 80vw; min-height: 80vh; width: 100%; height: 100%">
              <q-bar class="bg-brand-light">
                <h5 class="text-brand-text">{{ title }}</h5>
                <q-space></q-space>
                <q-btn @click="hideDialog" color="white" flat icon="close"></q-btn>
              </q-bar>

              <div class="fit">
                <q-pdfviewer
                  v-if="openedFile.content_type === 'application/pdf'"
                  type="html5"
                  :src="'/minio/download?id=' + openedFile.id"
                />
                <q-img
                  v-else
                  fit="contain"
                  style="max-width: 100%; height: 1000px"
                  :src="'/minio/download?id=' + openedFile.id"
                />
              </div>
            </q-card>
          </q-dialog>
        </q-card-section>

        <!-- AI Liquidation -->
        <q-card-section>
          <div class="text-h5 q-mb-md">AI Liquidation</div>
          <q-banner inline-actions class="text-white bg-red" v-if="formData.aiResult.liquidationResult === 'notOk'">
            Automatic liquidation finished with negative result with probability
            {{ formData.aiResult.aiConfidence * 100 }}%.
          </q-banner>
          <q-banner inline-actions class="text-white bg-green" v-if="formData.aiResult.liquidationResult === 'ok'">
            Automatic liquidation finished successfully with probability
            {{ formData.aiResult.aiConfidence * 100 }}% with amount {{ formData.claim.finalAmountOfDamage }} CZK.
          </q-banner>

          <q-table
            :rows="formData.aiResult.checks"
            row-key="id"
            :rows-per-page-options="[0]"
            :columns="aiColumns"
            @row-click="openDialog"
          />
        </q-card-section>
      </div>

      <!-- Payment information -->
      <q-card-section>
        <div class="text-h5 q-mb-md">Payment information</div>
        <div class="col-6"><label>Account number</label><q-input filled v-model="formData.claim.iban" /></div>
      </q-card-section>

      <!-- Confirmation -->
      <q-card-section>
        <div class="text-h5 q-mb-md">Confirmation</div>
        <q-checkbox v-model="formData.consent" label="I agree with the terms and conditions" required />
      </q-card-section>

      <!-- Police involvement -->
      <q-card-section>
        <div class="text-h5 q-mb-md">Was the incident reported to the police?</div>
        <q-radio v-model="formData.claim.policeInvolved" val="YES" label="Yes" />
        <q-radio v-model="formData.claim.policeInvolved" val="NO" label="No" />
      </q-card-section>
      <q-btn type="submit" label="Submit" color="primary" class="q-ma-xl" />
    </q-form>
  </q-page>
</template>

<script setup>
import { onMounted, ref, watch } from "vue";
import {
  QPage,
  QForm,
  QCardSection,
  QInput,
  QSelect,
  QTable,
  QDialog,
  QCard,
  QBar,
  QSpace,
  QBtn,
  QPdfviewer,
  QImg,
  QBanner,
  QCheckbox,
  QRadio,
} from "quasar";

const props = defineProps(["modelValue"]);
const emit = defineEmits(["submit"]);

const formData = ref(props.modelValue); // Create a local copy
const slide = ref(1);
const fullscreen = ref(false);

const openedFile = ref([]);

const columns = [
  {
    name: "filename",
    align: "left",
    label: "Filename",
    field: (row) => row.filename,
  },
  {
    name: "mimeType",
    align: "left",
    label: "MIME type",
    field: (row) => row.content_type,
  },
  {
    name: "size",
    align: "left",
    label: "Size",
    field: (row) => {
      const size = row.size;
      if (size < 1024) return size + " B";
      if (size < 1024 * 1024) return (size / 1024).toFixed(2) + " kB";
      if (size < 1024 * 1024 * 1024) return (size / (1024 * 1024)).toFixed(2) + " MB";
      return (size / (1024 * 1024 * 1024)).toFixed(2) + " GB";
    },
  },
];

const aiColumns = [
  {
    name: "result",
    align: "left",
    label: "Result",
    field: (row) => (row.result === "ok" ? "✅" : "❌"),
  },
  {
    name: "name",
    align: "left",
    label: "Check",
    field: (row) => row.name,
  },
  {
    name: "description",
    align: "left",
    label: "Description",
    field: (row) => row.description,
  },
];

const showDialog = ref(false);

function openDialog(evt, file) {
  openedFile.value = file;
  showDialog.value = true;
}

function hideDialog() {
  showDialog.value = false;
}

if (!formData.value.claim) {
  formData.value.claim = {};
}
if (!formData.value.input) {
  formData.value.input = {};
}

if (typeof formData.value.consent === "undefined") {
  formData.value.consent = false;
}

// onMounted(() => {
//   emit("update:modelValue", formData.value);
// });

// // Watch localValue and emit changes to the parent
// watch(formData.value, (newValue) => {
//     emit("update:modelValue", newValue);
// });

const insuranceOptions = ref([
  { label: "Property insurance", value: "MAJ" },
  { label: "Vehicle insurance", value: "POV_HAV" },
]);

const submit = () => {
  console.log(formData.value);
  emit("submit", formData.value);
};
</script>
