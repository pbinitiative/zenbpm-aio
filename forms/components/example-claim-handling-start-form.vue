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
          <div class="col-12">
            <label>Incident description</label
            ><q-input filled type="textarea" v-model="formData.claim.description" required />
          </div>
        </div>
      </q-card-section>

      <!-- Insured property -->
      <q-card-section>
        <div class="text-h5 q-mb-md">Insured property</div>
        <div class="row q-col-gutter-md">
          <div class="col-6">
            <label>Insurance type</label
            ><q-select filled v-model="formData.claim.insuranceType" :options="insuranceOptions" required />
          </div>
          <div class="col-6">
            <label>Property description</label
            ><q-input filled v-model="formData.claim.descriptionOfDamagedProperty" required />
          </div>
        </div>
      </q-card-section>

      <!-- Attachments -->
      <q-card-section>
        <div class="text-h5 q-mb-md">Attachments</div>
        <q-file v-model="files" label="Upload files" filled multiple style="max-width: 300px" />
      </q-card-section>

      <!-- Payment information -->
      <q-card-section>
        <div class="text-h5 q-mb-md">Payment information</div>
        <div class="col-6"><label>Bank account number</label><q-input filled v-model="formData.claim.iban" /></div>
      </q-card-section>

      <!-- Request confirmation -->
      <q-card-section>
        <div class="text-h5 q-mb-md">Request confirmation</div>
        <q-checkbox v-model="formData.consent" label="I agree to the terms and conditions" required />
      </q-card-section>

      <!-- Police involvement -->
      <q-card-section>
        <div class="text-h5 q-mb-md">Was the police involved?</div>
        <q-radio v-model="formData.claim.policeInvolved" val="true" label="Yes" />
        <q-radio v-model="formData.claim.policeInvolved" val="false" label="No" />
      </q-card-section>
      <q-btn type="submit" label="Submit" color="primary" class="q-ma-xl" />
    </q-form>
  </q-page>
</template>

<script setup>
import { onMounted, ref, watch } from "vue";
import { QPage, QForm, QCardSection, QInput, QSelect, QFile, QCheckbox, QRadio, QBtn } from "quasar";

const props = defineProps(["modelValue"]);
const emit = defineEmits(["submit"]);

const files = ref([]);
const formData = ref(props.modelValue); // Create a local copy
formData.value = {
  claim: {
    contractId: "12345",
    name: "Adam Klíma",
    address: "Exmple 12, 12345, Address",
    email: "adam.klima@ibpm.cz",
    date: "03/12/2025",
    placeOfDamage: "Place address",
    description: "Through description",
    damageCause: "Damage cause",
    amountOfDamage: 100000,
    insuranceType: "MAJ",
    descriptionOfDamagedProperty: "Through description",
    iban: "1234",
    policeInvolved: true,
  },
  input: {
    phoneNumber: "123456",
  },
  consent: true,
  files: [],
};

const insuranceOptions = ref([
  { label: "Property insurance", value: "MAJ" },
  { label: "Vehicle insurance", value: "POV_HAV" },
]);
onMounted(() => {
  //load insuracneOptionTypes form api
});

const uploadFiles = () => {
  files.value.forEach((file) => {
    const data = new FormData();
    data.append("file", file);

    fetch("/minio/upload", {
      method: "POST",
      body: data,
    })
      .then((response) => response.json())
      .then((data) => {
        console.log(data);
        formData.value.files.push(data);
      })
      .catch((error) => console.error("Error uploading file:", error));
  });
};

// Watch selectedFiles and upload when files change
watch(files, (newFiles) => {
  if (newFiles.length > 0) {
    uploadFiles();
  }
});

const submit = () => {
  console.log(formData.value);
  emit("submit", formData.value);
};
</script>
